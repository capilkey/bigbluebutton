import React, { PureComponent } from 'react';
import PropTypes from 'prop-types';
import { injectIntl, defineMessages } from 'react-intl';
import { PortalWithState } from 'react-portal';
import { styles } from './user-dropdown/styles';
import UserAvatar from '/imports/ui/components/user-avatar/component';
import Icon from '/imports/ui/components/icon/component';
import lockContextContainer from '/imports/ui/components/lock-viewers/context/container';
import UserName from './user-name/component';
import UserIcons from './user-icons/component';
import { Session } from 'meteor/session';
import cx from 'classnames';

import Dropdown from '/imports/ui/components/dropdown-portal/component';
import DropdownTrigger from '/imports/ui/components/dropdown-portal/trigger/component';
import DropdownContent from '/imports/ui/components/dropdown-portal/content/component';
import DropdownList from '/imports/ui/components/dropdown-portal/list/component';
import DropdownListItem from '/imports/ui/components/dropdown-portal/list/item/component';
import DropdownListSeparator from '/imports/ui/components/dropdown-portal/list/separator/component';

const propTypes = {
  compact: PropTypes.bool.isRequired,
  intl: PropTypes.shape({
    formatMessage: PropTypes.func.isRequired,
  }).isRequired,
  getAvailableActions: PropTypes.func.isRequired,
  isThisMeetingLocked: PropTypes.bool.isRequired,
  normalizeEmojiName: PropTypes.func.isRequired,
  getScrollContainerRef: PropTypes.func.isRequired,
  toggleUserLock: PropTypes.func.isRequired,
  isMeteorConnected: PropTypes.bool.isRequired,
};

const CHAT_ENABLED = Meteor.settings.public.chat.enabled;
const ROLE_MODERATOR = Meteor.settings.public.user.role_moderator;

const messages = defineMessages({
  presenter: {
    id: 'app.userList.presenter',
    description: 'Text for identifying presenter user',
  },
  you: {
    id: 'app.userList.you',
    description: 'Text for identifying your user',
  },
  locked: {
    id: 'app.userList.locked',
    description: 'Text for identifying locked user',
  },
  guest: {
    id: 'app.userList.guest',
    description: 'Text for identifying guest user',
  },
  menuTitleContext: {
    id: 'app.userList.menuTitleContext',
    description: 'adds context to userListItem menu title',
  },
  userAriaLabel: {
    id: 'app.userList.userAriaLabel',
    description: 'aria label for each user in the userlist',
  },
  statusTriggerLabel: {
    id: 'app.actionsBar.emojiMenu.statusTriggerLabel',
    description: 'label for option to show emoji menu',
  },
  backTriggerLabel: {
    id: 'app.audio.backLabel',
    description: 'label for option to hide emoji menu',
  },
  ChatLabel: {
    id: 'app.userList.menu.chat.label',
    description: 'Save the changes and close the settings menu',
  },
  ClearStatusLabel: {
    id: 'app.userList.menu.clearStatus.label',
    description: 'Clear the emoji status of this user',
  },
  takePresenterLabel: {
    id: 'app.actionsBar.actionsDropdown.takePresenter',
    description: 'Set this user to be the presenter in this meeting',
  },
  makePresenterLabel: {
    id: 'app.userList.menu.makePresenter.label',
    description: 'label to make another user presenter',
  },
  RemoveUserLabel: {
    id: 'app.userList.menu.removeUser.label',
    description: 'Forcefully remove this user from the meeting',
  },
  MuteUserAudioLabel: {
    id: 'app.userList.menu.muteUserAudio.label',
    description: 'Forcefully mute this user',
  },
  UnmuteUserAudioLabel: {
    id: 'app.userList.menu.unmuteUserAudio.label',
    description: 'Forcefully unmute this user',
  },
  PromoteUserLabel: {
    id: 'app.userList.menu.promoteUser.label',
    description: 'Forcefully promote this viewer to a moderator',
  },
  DemoteUserLabel: {
    id: 'app.userList.menu.demoteUser.label',
    description: 'Forcefully demote this moderator to a viewer',
  },
  UnlockUserLabel: {
    id: 'app.userList.menu.unlockUser.label',
    description: 'Unlock individual user',
  },
  LockUserLabel: {
    id: 'app.userList.menu.lockUser.label',
    description: 'Lock a unlocked user',
  },
  DirectoryLookupLabel: {
    id: 'app.userList.menu.directoryLookup.label',
    description: 'Directory lookup',
  },
});

class UserListItem extends PureComponent {
  constructor(props) {
    super(props);

    this.state = {
      isActionsOpen: false,
    };

    this.onMenuOpen = this.onMenuOpen.bind(this);
    this.onActionsHide = this.onActionsHide.bind(this);
  }

  onMenuOpen() {
    console.log(this.dropdown);
    // TODO: Store the item ref and then get the bounding box. Calculate global position and set styles in state. Once in state set in the portal after.
  }

  getDropdownMenuParent() {
    return findDOMNode(this.dropdown);
  }

  makeDropdownItem(key, label, onClick, icon = null, iconRight = null) {
    const { getEmoji } = this.props;
    return (
      <DropdownListItem
        {...{
          key,
          label,
          onClick,
          icon,
          iconRight,
        }}
        className={key === getEmoji ? styles.emojiSelected : null}
        data-test={key}
      />
    );
  }

  onActionsHide(callback) {
    const { getScrollContainerRef } = this.props;

    this.setState({
      isActionsOpen: false,
      dropdownVisible: false,
      showNestedOptions: false,
    });

    const scrollContainer = getScrollContainerRef();
    scrollContainer.removeEventListener('scroll', this.handleScroll, false);

    if (callback) {
      return callback;
    }

    return Session.set('dropdownOpen', false);
  }

  getUsersActions() {
    const {
      intl,
      currentUser,
      user,
      voiceUser,
      getAvailableActions,
      getGroupChatPrivate,
      getEmojiList,
      setEmojiStatus,
      assignPresenter,
      removeUser,
      toggleVoice,
      changeRole,
      lockSettingsProps,
      hasPrivateChatBetweenUsers,
      toggleUserLock,
      requestUserInformation,
      isMeteorConnected,
      userLocks,
      isMe,
      meetingIsBreakout,
    } = this.props;
    const { showNestedOptions } = this.state;

    const amIModerator = currentUser.role === ROLE_MODERATOR;
    const actionPermissions = getAvailableActions(amIModerator, meetingIsBreakout, user, voiceUser);
    const actions = [];

    const {
      allowedToChatPrivately,
      allowedToMuteAudio,
      allowedToUnmuteAudio,
      allowedToResetStatus,
      allowedToRemove,
      allowedToSetPresenter,
      allowedToPromote,
      allowedToDemote,
      allowedToChangeStatus,
      allowedToChangeUserLockStatus,
    } = actionPermissions;

    const { disablePrivateChat } = lockSettingsProps;

    const enablePrivateChat = currentUser.role === ROLE_MODERATOR
      ? allowedToChatPrivately
      : allowedToChatPrivately
      && (!(currentUser.locked && disablePrivateChat)
        || hasPrivateChatBetweenUsers(currentUser.userId, user.userId)
        || user.role === ROLE_MODERATOR) && isMeteorConnected;

    const { allowUserLookup } = Meteor.settings.public.app;

    if (!isMeteorConnected) return actions;

    if (showNestedOptions) {
      if (allowedToChangeStatus) {
        actions.push(this.makeDropdownItem(
          'back',
          intl.formatMessage(messages.backTriggerLabel),
          () => this.setState(
            {
              showNestedOptions: false,
              isActionsOpen: true,
            }, Session.set('dropdownOpen', true),
          ),
          'left_arrow',
        ));
      }

      actions.push(<DropdownListSeparator key={_.uniqueId('list-separator-')} />);

      const statuses = Object.keys(getEmojiList);
      statuses.map(status => actions.push(this.makeDropdownItem(
        status,
        intl.formatMessage({ id: `app.actionsBar.emojiMenu.${status}Label` }),
        () => { setEmojiStatus(user.userId, status); this.resetMenuState(); },
        getEmojiList[status],
      )));

      return actions;
    }

    if (allowedToChangeStatus) {
      actions.push(this.makeDropdownItem(
        'setstatus',
        intl.formatMessage(messages.statusTriggerLabel),
        () => this.setState(
          {
            showNestedOptions: true,
            isActionsOpen: true,
          }, Session.set('dropdownOpen', true),
        ),
        'user',
        'right_arrow',
      ));
    }

    if (CHAT_ENABLED && enablePrivateChat) {
      actions.push(this.makeDropdownItem(
        'activeChat',
        intl.formatMessage(messages.ChatLabel),
        () => {
          getGroupChatPrivate(currentUser.userId, user);
          Session.set('openPanel', 'chat');
          Session.set('idChatOpen', user.userId);
        },
        'chat',
      ));
    }

    if (allowedToResetStatus && user.emoji !== 'none') {
      actions.push(this.makeDropdownItem(
        'clearStatus',
        intl.formatMessage(messages.ClearStatusLabel),
        () => this.onActionsHide(setEmojiStatus(user.userId, 'none')),
        'clear_status',
      ));
    }

    if (allowedToMuteAudio) {
      actions.push(this.makeDropdownItem(
        'mute',
        intl.formatMessage(messages.MuteUserAudioLabel),
        () => this.onActionsHide(toggleVoice(user.userId)),
        'mute',
      ));
    }

    if (allowedToUnmuteAudio && !userLocks.userMic) {
      actions.push(this.makeDropdownItem(
        'unmute',
        intl.formatMessage(messages.UnmuteUserAudioLabel),
        () => this.onActionsHide(toggleVoice(user.userId)),
        'unmute',
      ));
    }

    if (allowedToSetPresenter) {
      actions.push(this.makeDropdownItem(
        'setPresenter',
        isMe(user.userId)
          ? intl.formatMessage(messages.takePresenterLabel)
          : intl.formatMessage(messages.makePresenterLabel),
        () => this.onActionsHide(assignPresenter(user.userId)),
        'presentation',
      ));
    }

    if (allowedToRemove) {
      actions.push(this.makeDropdownItem(
        'remove',
        intl.formatMessage(messages.RemoveUserLabel, { 0: user.name }),
        () => this.onActionsHide(removeUser(user.userId)),
        'circle_close',
      ));
    }

    if (allowedToPromote) {
      actions.push(this.makeDropdownItem(
        'promote',
        intl.formatMessage(messages.PromoteUserLabel),
        () => this.onActionsHide(changeRole(user.userId, 'MODERATOR')),
        'promote',
      ));
    }

    if (allowedToDemote) {
      actions.push(this.makeDropdownItem(
        'demote',
        intl.formatMessage(messages.DemoteUserLabel),
        () => this.onActionsHide(changeRole(user.userId, 'VIEWER')),
        'user',
      ));
    }

    if (allowedToChangeUserLockStatus) {
      const userLocked = user.locked && user.role !== ROLE_MODERATOR;
      actions.push(this.makeDropdownItem(
        'unlockUser',
        userLocked ? intl.formatMessage(messages.UnlockUserLabel, { 0: user.name })
          : intl.formatMessage(messages.LockUserLabel, { 0: user.name }),
        () => this.onActionsHide(toggleUserLock(user.userId, !userLocked)),
        userLocked ? 'unlock' : 'lock',
      ));
    }

    if (allowUserLookup) {
      actions.push(this.makeDropdownItem(
        'directoryLookup',
        intl.formatMessage(messages.DirectoryLookupLabel),
        () => this.onActionsHide(requestUserInformation(user.extId)),
        'user',
      ));
    }

    return actions;
  }

  renderUserAvatar() {
    const {
      normalizeEmojiName,
      user,
      userInBreakout,
      breakoutSequence,
      meetingIsBreakout,
      voiceUser,
    } = this.props;

    const { clientType } = user;
    const isVoiceOnly = clientType === 'dial-in-user';

    const iconUser = user.emoji !== 'none'
      ? (<Icon iconName={normalizeEmojiName(user.emoji)} />)
      : user.name.toLowerCase().slice(0, 2);

    const iconVoiceOnlyUser = (<Icon iconName="audio_on" />);
    const userIcon = isVoiceOnly ? iconVoiceOnlyUser : iconUser;

    return (
      <UserAvatar
        moderator={user.role === ROLE_MODERATOR}
        presenter={user.presenter}
        talking={voiceUser.isTalking}
        muted={voiceUser.isMuted}
        listenOnly={voiceUser.isListenOnly}
        voice={voiceUser.isVoiceUser}
        noVoice={!voiceUser.isVoiceUser}
        color={user.color}
      >
        {
        userInBreakout
        && !meetingIsBreakout
          ? breakoutSequence : userIcon}
      </UserAvatar>
    );
  }

  renderItem(onClick, isOpen, actions) {
    const {
      user,
      assignPresenter,
      compact,
      currentUser,
      changeRole,
      getAvailableActions,
      getEmoji,
      getEmojiList,
      getGroupChatPrivate,
      getScrollContainerRef,
      intl,
      isThisMeetingLocked,
      lockSettingsProps,
      normalizeEmojiName,
      removeUser,
      setEmojiStatus,
      toggleVoice,
      hasPrivateChatBetweenUsers,
      toggleUserLock,
      requestUserInformation,
      userInBreakout,
      breakoutSequence,
      meetingIsBreakout,
      isMeteorConnected,
      isMe,
      voiceUser,
    } = this.props;

    const {
      isActionsOpen,
    } = this.state;

    const userItemContentsStyle = {};

    userItemContentsStyle[styles.dropdown] = true;
    userItemContentsStyle[styles.userListItem] = !isOpen;
    userItemContentsStyle[styles.usertListItemWithMenu] = isOpen;

    const you = isMe(user.userId) ? intl.formatMessage(messages.you) : '';

    const presenter = (user.presenter)
      ? intl.formatMessage(messages.presenter)
      : '';

    const userAriaLabel = intl.formatMessage(
      messages.userAriaLabel,
      {
        0: user.name,
        1: presenter,
        2: you,
        3: user.emoji,
      },
    );

    return (
      <div
        ref={(ref) => { this.dropdown = ref; }}
        data-test={isMe(user.userId) ? 'userListItemCurrent' : null}
        className={cx(!actions.length || styles.userListItem, userItemContentsStyle)}
        onClick={onClick}
      >
        <div className={styles.userItemContents}>
          <div className={styles.userAvatar}>
            {this.renderUserAvatar()}
          </div>
          {<UserName
            {...{
              user,
              compact,
              intl,
              isThisMeetingLocked,
              userAriaLabel,
              isActionsOpen,
              isMe,
            }}
          />}
          {<UserIcons
            {...{
              user,
              amIModerator: currentUser.role === ROLE_MODERATOR,
            }}
          />}
        </div>
      </div>
    );
  }

  render() {
    const actions = this.getUsersActions();

    const portalStyle = {
      position: 'absolute',
      top: 100,
      left: 100,
      // height: "100px",
      //  width: "150px",
      zIndex: 100,
    //  background: "white",
    };

    return (
      <PortalWithState closeOnOutsideClick closeOnEsc onOpen={this.onMenuOpen}>
        {({
          openPortal, closePortal, isOpen, portal,
        }) => (
          <React.Fragment>
            {this.renderItem(openPortal, isOpen, actions)}
            {portal(
              <DropdownContent
                style={{
                  visibility: 'visible',
                  position: 'absolute',
                  top: 100,
                  left: 100,
                  zIndex: 100,
                }}
                className={styles.dropdownContent}
                placement="right top"
              >
                <DropdownList
                  ref={(ref) => { this.list = ref; }}
                  getDropdownMenuParent={this.getDropdownMenuParent}
                  onActionsHide={this.onActionsHide}
                >
                  {actions}
                </DropdownList>
              </DropdownContent>,
            )}
          </React.Fragment>
        )}
      </PortalWithState>
    );
  }
}

UserListItem.propTypes = propTypes;

export default injectIntl(lockContextContainer(UserListItem));

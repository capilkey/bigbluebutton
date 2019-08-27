import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { FormattedTime } from 'react-intl';
import _ from 'lodash';

import Message from './message/component';

import { styles } from './styles';

const propTypes = {
  message: PropTypes.shape({
    senderId: PropTypes.string,
    senderName: PropTypes.string,
    content: PropTypes.arrayOf(Object).isRequired,
    timestamp: PropTypes.number.isRequired,
  }).isRequired,
  scrollArea: PropTypes.instanceOf(Element),
  chatAreaId: PropTypes.string.isRequired,
  handleReadMessage: PropTypes.func.isRequired,
  lastReadMessageTime: PropTypes.number,
};

const defaultProps = {
  scrollArea: undefined,
  lastReadMessageTime: 0,
};

const eventsToBeBound = [
  'scroll',
  'resize',
];

const isElementInViewport = (el) => {
  if (!el) return false;
  const rect = el.getBoundingClientRect();
  const prefetchHeight = 125;

  return (rect.top >= -(prefetchHeight) || rect.bottom >= -(prefetchHeight));
};

class MessageListItem extends Component {
  constructor(props) {
    super(props);

    this.state = {
      pendingChanges: false,
      preventRender: true,
    };

    this.handleMessageInViewport = _.debounce(this.handleMessageInViewport.bind(this), 50);
  }

  componentDidMount() {
    const { scrollArea } = this.props;

    if (scrollArea) {
      eventsToBeBound.forEach(
        (e) => { scrollArea.addEventListener(e, this.handleMessageInViewport, false); },
      );
    }
    this.handleMessageInViewport();
  }

  componentWillReceiveProps(nextProps) {
    const { message } = this.props;
    const { content, senderId } = message;
    const { pendingChanges } = this.state;
    if (pendingChanges) return;

    const hasNewMessage = content.length !== nextProps.message.content.length;
    const hasUserChanged = senderId !== nextProps.message.senderId;

    this.setState({ pendingChanges: hasNewMessage || hasUserChanged });
  }

  shouldComponentUpdate(nextProps, nextState) {
    const { scrollArea } = this.props;
    if (!scrollArea && nextProps.scrollArea) return true;
    return !nextState.preventRender && nextState.pendingChanges;
  }

  componentDidUpdate(prevProps, prevState) {
    const {
      preventRender,
      pendingChanges,
    } = this.state;
    if (prevState.preventRender && !preventRender && pendingChanges) {
      this.setPendingChanges(false);
    }
  }

  componentWillUnmount() {
    const { scrollArea } = this.props;

    if (scrollArea) {
      eventsToBeBound.forEach(
        (e) => { scrollArea.removeEventListener(e, this.handleMessageInViewport, false); },
      );
    }
  }

  setPendingChanges(pendingChanges) {
    this.setState({ pendingChanges });
  }

  handleMessageInViewport() {
    window.requestAnimationFrame(() => {
      const node = this.item;
      if (node) this.setState({ preventRender: !isElementInViewport(node) });
    });
  }

  renderSystemMessage() {
    const {
      message,
      chatAreaId,
      handleReadMessage,
    } = this.props;

    return (
      <div>
        {message.content.map(item => (
          item.text !== ''
            ? (
              <Message
                className={(item.id ? styles.systemMessage : null)}
                key={_.uniqueId('id-')}
                text={item.text}
                time={item.time}
                chatAreaId={chatAreaId}
                handleReadMessage={handleReadMessage}
              />
            ) : null
        ))}
      </div>
    );
  }

  render() {
    const {
      message,
      chatAreaId,
      lastReadMessageTime,
      handleReadMessage,
      scrollArea,
    } = this.props;

    const {
      senderId,
      senderName,
      timestamp,
      content,
    } = message;

    const dateTime = new Date(timestamp);

    const regEx = /<a[^>]+>/i;

    if (!senderId) {
      return this.renderSystemMessage();
    }

    return (
      <div className={styles.item}>
        <div className={styles.wrapper} ref={(ref) => { this.item = ref; }}>
          <div className={styles.content}>
            <div className={styles.meta}>
              <div className={styles.name}>
                <span>{senderName}</span>
              </div>
              <time className={styles.time} dateTime={dateTime}>
                <FormattedTime value={dateTime} />
              </time>
            </div>
            <div>
              {content.map(item => (
                <Message
                  className={(regEx.test(item.text) ? styles.hyperlink : styles.message)}
                  key={item.id}
                  text={item.text}
                  time={item.time}
                  chatAreaId={chatAreaId}
                  lastReadMessageTime={lastReadMessageTime}
                  handleReadMessage={handleReadMessage}
                  scrollArea={scrollArea}
                />
              ))}
            </div>
          </div>
        </div>
      </div>
    );
  }
}

MessageListItem.defaultProps = defaultProps;
MessageListItem.propTypes = propTypes;

export default MessageListItem;

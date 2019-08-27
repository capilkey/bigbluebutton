import React, { PureComponent } from 'react';
import PropTypes from 'prop-types';
import _ from 'lodash';

const propTypes = {
  text: PropTypes.string.isRequired,
  time: PropTypes.number.isRequired,
  lastReadMessageTime: PropTypes.number,
  handleReadMessage: PropTypes.func.isRequired,
  scrollArea: PropTypes.instanceOf(Element),
  className: PropTypes.string.isRequired,
};

const defaultProps = {
  lastReadMessageTime: 0,
  scrollArea: undefined,
};

const eventsToBeBound = [
  'scroll',
  'resize',
];

const isElementInViewport = (el) => {
  if (!el) return false;
  const rect = el.getBoundingClientRect();

  return (
    rect.top >= 0
    && rect.left >= 0
    && rect.bottom <= (window.innerHeight || document.documentElement.clientHeight)
    && rect.right <= (window.innerWidth || document.documentElement.clientWidth)
  );
};

export default class MessageListItem extends PureComponent {
  constructor(props) {
    super(props);

    this.ticking = false;

    this.handleMessageInViewport = _.debounce(this.handleMessageInViewport.bind(this), 50);
  }

  componentDidMount() {
    this.listenToUnreadMessages();
  }

  componentDidUpdate() {
    this.listenToUnreadMessages();
  }

  componentWillUnmount() {
    const {
      // lastReadMessageTime,
      // time,
      scrollArea,
    } = this.props;

    // This was added 3 years ago, but never worked. Leaving it around in case someone returns
    // and decides it needs to be fixed like the one in listenToUnreadMessages()
    // if (!lastReadMessageTime > time) {
    //  return;
    // }

    if (scrollArea) {
      eventsToBeBound.forEach(
        (e) => { scrollArea.removeEventListener(e, this.handleMessageInViewport, false); },
      );
    }
  }

  // depending on whether the message is in viewport or not,
  // either read it or attach a listener
  listenToUnreadMessages() {
    const {
      lastReadMessageTime,
      time,
      scrollArea,
      handleReadMessage,
    } = this.props;

    if (lastReadMessageTime > time) {
      return;
    }

    const node = this.text;

    if (isElementInViewport(node)) { // no need to listen, the message is already in viewport
      handleReadMessage(time);
    } else if (scrollArea) {
      eventsToBeBound.forEach(
        (e) => { scrollArea.addEventListener(e, this.handleMessageInViewport, false); },
      );
    }
  }

  handleMessageInViewport() {
    const {
      scrollArea,
      handleReadMessage,
      time,
    } = this.props;

    if (!this.ticking) {
      window.requestAnimationFrame(() => {
        const node = this.text;

        if (isElementInViewport(node)) {
          handleReadMessage(time);
          if (scrollArea) {
            eventsToBeBound.forEach(
              e => scrollArea.removeEventListener(e, this.handleMessageInViewport),
            );
          }
        }

        this.ticking = false;
      });
    }

    this.ticking = true;
  }

  render() {
    const {
      text,
      className,
    } = this.props;

    return (
      <p
        ref={(ref) => { this.text = ref; }}
        dangerouslySetInnerHTML={{ __html: text }}
        className={className}
      />
    );
  }
}

MessageListItem.defaultProps = defaultProps;
MessageListItem.propTypes = propTypes;

import Sharing from 'discourse/lib/sharing';
import { withPluginApi } from 'discourse/lib/plugin-api';

function initializeWithApi(api) {
  const siteSettings = api.container.lookup('site-settings:main');
  if (!siteSettings.zh_l10n_enabled) return;

  addSharingSources();
}

function addSharingSources() {
  Sharing.addSource({
    id: 'weibo',
    faIcon: 'fa-weibo',
    title: I18n.t('share.weibo'),
    generateUrl(link, title) {
      return "http://service.weibo.com/share/share.php?url=" + encodeURIComponent(link) + "&title=" + encodeURIComponent(title);
    },
    shouldOpenInPopup: true,
    popupHeight: 370
  });

  Sharing.addSource({
    id: 'renren',
    faIcon: 'fa-renren',
    title: I18n.t('share.renren'),
    generateUrl(link, title) {
      return "http://widget.renren.com/dialog/share?resourceUrl=" + encodeURIComponent(link) + "&title=" + encodeURIComponent(title) + "&description=" + encodeURIComponent(title);
    },
    shouldOpenInPopup: true,
    popupHeight: 628
  });

  Sharing.addSource({
    id: 'wechat',
    faIcon: 'fa-weixin',
    title: I18n.t('share.wechat'),
    generateUrl(link) {
      return "http://s.jiathis.com/qrcode.php?url=" + encodeURIComponent(link);
    },
    shouldOpenInPopup: true,
    popupHeight: 200
  });

  Sharing.addSource({
    id: 'tencent_weibo',
    faIcon: 'fa-tencent-weibo',
    title: I18n.t('share.tencent_weibo'),
    generateUrl(link, title) {
      return "http://share.v.t.qq.com/index.php?c=share&a=index&url=" + encodeURIComponent(link) + "&title=" + encodeURIComponent(title);
    },
    shouldOpenInPopup: true,
    popupHeight: 200
  });

  Sharing.addSource({
    id: 'qzone',
    faIcon: 'fa-qq', // need a image
    title: I18n.t('share.qzone'),
    generateUrl(link, title) {
      // http://sns.qzone.qq.com/cgi-bin/qzshare/cgi_qzshare_onekey?url=http://meta.discoursecn.org&desc=TestApi&title=theApiTest&pics=https://dn-discoursecn.qbox.me/uploads/default/4/ead61e7ddc99b2e6.png&site=http://meta.discoursecn.org
      return "http://sns.qzone.qq.com/cgi-bin/qzshare/cgi_qzshare_onekey?url=" + encodeURIComponent(link) + "&title=" + encodeURIComponent(title) + "&desc=" + encodeURIComponent(title);
    },
    shouldOpenInPopup: true,
    popupHeight: 200
  });

  Sharing.addSource({
    id: 'douban',
    faIcon: '豆', // need a image
    title: I18n.t('share.douban'),
    generateUrl(link, title) {
      return "http://shuo.douban.com/!service/share?href" + encodeURIComponent(link) + "&name=" + encodeURIComponent(title) + "&text=" + encodeURIComponent(title);
    },
    shouldOpenInPopup: true,
    popupHeight: 200
  });
}

export default {
  name: 'discourse-chinese-localization-pack',

  initialize() {
    withPluginApi('0.1', initializeWithApi);
  }
}

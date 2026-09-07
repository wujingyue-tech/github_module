// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'GitHub 学习';

  @override
  String get loginTitle => 'GitHub 登录';

  @override
  String get loginSubtitle =>
      'GitHub 已不再支持账号密码调用 API。\n本示例使用 Personal Access Token 登录。';

  @override
  String get tokenLabel => 'Personal Access Token';

  @override
  String get tokenHint => '以 ghp_ 或 github_pat_ 开头';

  @override
  String get signIn => '登录';

  @override
  String get tokenHelp =>
      '如何获取 Token\n1. 打开 github.com/settings/tokens\n2. Generate new token (classic)\n3. 勾选 read:user（个人信息）和 repo（仓库列表，含私有仓）\n4. 生成后粘贴到上方（只显示一次，请保存好）';

  @override
  String get loggedIn => '已登录';

  @override
  String get signOut => '退出';

  @override
  String get savedToken => '已保存 Token';

  @override
  String get settings => '设置';

  @override
  String get debugLogs => '日志';

  @override
  String get language => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get languageChinese => '中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get appearance => '外观';

  @override
  String get appearanceSystem => '跟随系统';

  @override
  String get appearanceLight => '浅色';

  @override
  String get appearanceDark => '深色';

  @override
  String get themeColor => '主题色';

  @override
  String get colorBlue => '蓝色';

  @override
  String get colorCyan => '青色';

  @override
  String get colorTeal => '蓝绿';

  @override
  String get colorGreen => '绿色';

  @override
  String get colorRed => '红色';

  @override
  String get colorOrange => '橙色';

  @override
  String get colorPurple => '紫色';

  @override
  String get colorPink => '粉色';

  @override
  String get colorIndigo => '靛蓝';

  @override
  String get authErrorEmptyToken => '请输入 Token';

  @override
  String get authErrorEmptyResponse => '服务器返回为空';

  @override
  String get authErrorInvalidToken => 'Token 无效或已过期，请到 GitHub 重新生成';

  @override
  String get authErrorForbidden => '权限不足，Token 需要至少能读取用户信息（read:user）';

  @override
  String get authErrorTimeout => '连接超时，请检查网络';

  @override
  String get authErrorOffline => '当前没有网络连接';

  @override
  String get authErrorRateLimited => '请求过于频繁，请稍后再试';

  @override
  String get authErrorParseFailed => '无法解析服务器返回的数据';

  @override
  String get authErrorFailed => '请求失败';

  @override
  String get reposTab => '仓库';

  @override
  String get profileTab => '我的';

  @override
  String get reposTitle => '仓库';

  @override
  String get profileTitle => '个人信息';

  @override
  String get reposEmpty => '还没有仓库';

  @override
  String get repoPrivate => '私有';

  @override
  String get repoNoDescription => '暂无描述';

  @override
  String get retry => '重试';

  @override
  String get publicRepos => '仓库';

  @override
  String get privateRepos => '私有';

  @override
  String get followers => '关注者';

  @override
  String get following => '关注中';

  @override
  String joinedAt(String date) {
    return '加入于 $date';
  }

  @override
  String starCount(int count) {
    return '$count 星';
  }

  @override
  String forkCount(int count) {
    return '$count 分支';
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

final class AppAssets {
  AppAssets._();

  static const String loginIllustration = 'assets/icons/login/Overlay.svg';
  static const String googleLogo = 'assets/icons/login/google_icon.svg';
}

final class AppIcons {
  AppIcons._();

  static const IconData home = Icons.home_rounded;
  static const IconData history = Icons.history_rounded;
  static const IconData leaves = Icons.calendar_month_rounded;
  static const IconData profile = Icons.person_rounded;

  static const IconData calendarSearch = Icons.event_note_rounded;
  static const IconData calendarOutline = Icons.calendar_today_outlined;
  static const IconData calendarTick = Icons.event_available_outlined;
  static const IconData calendarRemove = Icons.event_busy_outlined;

  static const IconData warning = Icons.warning_amber_rounded;
  static const IconData check = Icons.check_circle_outline_rounded;
  static const IconData checkSquare = Icons.check_box_outlined;
  static const IconData close = Icons.close_rounded;
  static const IconData closeCircle = Icons.cancel_outlined;
  static const IconData add = Icons.add_rounded;
  static const IconData chat = Icons.forum_outlined;
  static const IconData send = Icons.send_rounded;
  static const IconData calendarEdit = Icons.edit_calendar_outlined;

  static const IconData arrowBack = Icons.arrow_back_ios_new_rounded;
  static const IconData arrowForward = Icons.arrow_forward_ios_rounded;
  static const IconData arrowDown = Icons.keyboard_arrow_down_rounded;

  static const IconData login = Icons.login_rounded;
  static const IconData logout = Icons.logout_rounded;
  static const IconData lock = Icons.lock_outline_rounded;
  static const IconData touch = Icons.touch_app_rounded;
  static const IconData trendUp = Icons.trending_up_rounded;

  static const IconData present = Icons.verified_rounded;
  static const IconData absent = Icons.highlight_off_rounded;
  static const IconData halfDay = Icons.timelapse_rounded;
  static const IconData pending = Icons.hourglass_top_rounded;
  static const IconData holiday = Icons.beach_access_rounded;

  static const IconData profileCard = Icons.badge_outlined;
  static const IconData profileTick = Icons.verified_user_outlined;
  static const IconData people = Icons.people_outline_rounded;
  static const IconData mail = Icons.email_outlined;
  static const IconData location = Icons.location_on_outlined;
  static const IconData mobile = Icons.phone_android_outlined;

  static const IconData clock = Icons.schedule_outlined;
  static const IconData timer = Icons.timer_outlined;
}

class AppSvg extends StatelessWidget {
  const AppSvg(
    this.asset, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
  });

  final String asset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}

class GreetingHelper {
  static String greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return "早上好";
    if (hour < 17) return "下午好";
    return "晚上好";
  }
}

class AppHostingConstant {
  /// Base domain
  static const String baseUrl =
      "https://esportstestinternal.web.app";
      // "https://esports-test-531ca.web.app";

  /// App link
  static String app() => baseUrl;

  /// Post link
  static String post(String postId) => "$baseUrl/post_detail?postId=$postId";
  static String team(String teamId) =>
      "$baseUrl/teamPublicProfile?teamId=$teamId";
  static String shareJob(String jobId) => "$baseUrl/jobsDetails?jobId=$jobId";

  /// Profile link
  static String profile(String userId) =>
      "$baseUrl/publicProfile?userId=$userId";

  static String coachPorfile(String id) => "$baseUrl/coachProfile?coachUid=$id";

  static String channel(String id) => "$baseUrl/channel?channelId=$id";

  /// Feed (optional)
  static String feed() => "$baseUrl/feed";

  /// Shorts link
  static String shorts(String videoId) =>
      "$baseUrl/shorts_detail?videoId=$videoId";

  static String tournament(String tournamentId) =>
      "$baseUrl/tournamentDetail?tournamentId=$tournamentId";

  /// Recording link
  static String recording(String recordingId) =>
      "$baseUrl/recording_detail?id=$recordingId";
}

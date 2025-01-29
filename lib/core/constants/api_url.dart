const bool isLive = true;

const String apiBaseUrl = isLive == true
    ? "https://signumcode.in/api/"
    : "https://test.com/api/V1/";


class ApiUrl{

  static const String loginUrl = 'login';
  static const String registerUrl = 'signup';

}
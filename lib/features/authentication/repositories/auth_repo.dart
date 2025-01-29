import '../../../core/network/dio_client.dart';
import '../models/login_request_model.dart';
import '../models/user_model.dart';

class AuthRepository{

  DeoClient client = DeoClient();

  Future<UserModel> login(LoginRequestModel request) async {
      final response = await DeoClient.postData(url:'/login', data: request.toJson());
      return UserModel.fromJson(response.data);
  }

}
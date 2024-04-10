String formatPhoneNumber({required String phoneNumberWCountryCode}){
  return '0${phoneNumberWCountryCode.substring(4)}';
}
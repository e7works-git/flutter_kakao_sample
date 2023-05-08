import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

var loggerNoStack = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

class Log {
  demo(message) {
    return logger.d(message);
  }

  info(message) {
    return logger.i(message);
  }

  error(message) {
    return logger.e(message);
  }

  loggerNoStackInfo(message) {
    return loggerNoStack.i(message);
  }

  loggerNoStackWarn(message) {
    return loggerNoStack.w(message);
  }
}

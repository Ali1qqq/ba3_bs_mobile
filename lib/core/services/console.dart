// abstract class Coffee {
//   double cost();
//
//   String description();
// }
//
// class BasicCoffee implements Coffee {
//   @override
//   double cost() {
//     return 5.0; // Basic coffee cost
//   }
//
//   @override
//   String description() {
//     return 'Basic Coffee';
//   }
// }
//
// class CoffeeDecorator implements Coffee {
//   final Coffee coffee;
//
//   CoffeeDecorator(this.coffee);
//
//   @override
//   double cost() {
//     return coffee.cost();
//   }
//
//   @override
//   String description() {
//     return coffee.description();
//   }
// }
//
// class MilkDecorator extends CoffeeDecorator {
//   MilkDecorator(super.coffee);
//
//   @override
//   double cost() {
//     return super.cost() + 1.5; // Add the cost of milk
//   }
//
//   @override
//   String description() {
//     return '${super.description()}, with Milk';
//   }
// }
//
// class SugarDecorator extends CoffeeDecorator {
//   SugarDecorator(super.coffee);
//
//   @override
//   double cost() {
//     return super.cost() + 0.5; // Add the cost of sugar
//   }
//
//   @override
//   String description() {
//     return '${super.description()}, with Sugar';
//   }
// }
//
// void main() {
//   Coffee coffee = BasicCoffee();
//   print('${coffee.description()} costs \$${coffee.cost()}');
//
//   Coffee milkCoffee = MilkDecorator(coffee);
//   print('${milkCoffee.description()} costs \$${milkCoffee.cost()}');
//
//   Coffee sugarMilkCoffee = SugarDecorator(milkCoffee);
//   print('${sugarMilkCoffee.description()} costs \$${sugarMilkCoffee.cost()}');
// }



/// Virtual Proxy
// Step 1: Define the Subject (Interface)
abstract class Image {
  void display(); // Common method for both real and proxy images
}

// Step 2: Create the Real Subject (Expensive Object)
class RealImage implements Image {
  final String filename;

  RealImage(this.filename) {
    _loadFromDisk(); // Simulate expensive loading operation
  }

  void _loadFromDisk() {
    // print("Loading image from disk: $filename");
  }

  @override
  void display() {
    // print("Displaying image: $filename");
  }
}

// Step 3: Create the Proxy (Placeholder)
class ImageProxy implements Image {
  final String filename;
  RealImage? _realImage; // Lazy initialization of the real image

  ImageProxy(this.filename);

  @override
  void display() {
    _realImage ??= RealImage(filename);
    _realImage!.display();
  }
}

/// Remote Proxy
// Define the interface
abstract class RemoteService {
  Future<void> fetchData();
}

// Real service performing the actual work
class RealRemoteService implements RemoteService {
  @override
  Future<void> fetchData() async {
    // print("Fetching data from a remote server...");
    await Future.delayed(Duration(seconds: 2)); // Simulate network latency
    // print("Data fetched successfully!");
  }
}

// Proxy that monitors and forwards the request to the real service
class RemoteServiceProxy implements RemoteService {
  final RealRemoteService _remoteService = RealRemoteService();
  bool _isAuthenticated = false;

  RemoteServiceProxy({required bool isAuthenticated}) {
    _isAuthenticated = isAuthenticated;
  }

  @override
  Future<void> fetchData() async {
    if (!_isAuthenticated) {
      // print("Access denied: User is not authenticated!");
      return;
    }

    // print("Proxy: Forwarding request to the remote service...");
    await _remoteService.fetchData();
    // print("Proxy: Request completed.");
  }
}

/// Protection Proxy
abstract class Database {
  void query(String sql);
}

class RealDatabase implements Database {
  @override
  void query(String sql) {
    // print("Executing query: $sql");
  }
}

class DatabaseProxy implements Database {
  final String userRole;
  final RealDatabase _realDatabase = RealDatabase();

  DatabaseProxy(this.userRole);

  @override
  void query(String sql) {
    if (userRole == "admin") {
      _realDatabase.query(sql);
    } else {
      // print("Access denied: Insufficient permissions.");
    }
  }
}

/// Cache Proxy
abstract class WeatherService {
  String getWeather(String city);
}

class RealWeatherService implements WeatherService {
  @override
  String getWeather(String city) {
    // print("Fetching weather data for $city...");
    return "Sunny in $city";
  }
}

/// Cache Proxy
class CachedWeatherServiceProxy implements WeatherService {
  final RealWeatherService _realWeatherService = RealWeatherService();
  final Map<String, String> _cache = {};

  @override
  String getWeather(String city) {
    if (_cache.containsKey(city)) {
      // print("Returning cached weather for $city...");
      return _cache[city]!;
    }

    // print("Fetching new weather data...");
    String result = _realWeatherService.getWeather(city);
    _cache[city] = result;
    return result;
  }
}

/// Firewall Proxy
abstract class WebServer {
  void handleRequest(String ip);
}

class RealWebServer implements WebServer {
  @override
  void handleRequest(String ip) {
    // print("Handling request from IP: $ip");
  }
}

class FirewallProxy implements WebServer {
  final RealWebServer _webServer = RealWebServer();
  final List<String> _blockedIps = ["192.168.1.5", "192.168.1.6"];

  @override
  void handleRequest(String ip) {
    if (_blockedIps.contains(ip)) {
      // print("Blocked request from IP: $ip");
    } else {
      _webServer.handleRequest(ip);
    }
  }
}

/// Synchronization Proxy
abstract class BankAccount {
  Future<void> deposit(int amount);

  Future<void> withdraw(int amount);

  Future<int> get balance;
}

/// RealBankAccount: The actual bank account implementation
class RealBankAccount implements BankAccount {
  int _balance = 0;

  @override
  Future<void> deposit(int amount) async {
    _balance += amount;
    // print("Deposited \$${amount}. Current balance: \$$_balance");
  }

  @override
  Future<void> withdraw(int amount) async {
    if (_balance >= amount) {
      _balance -= amount;
      // print("Withdrew \$${amount}. Current balance: \$$_balance");
    } else {
      // print("Insufficient funds! Withdrawal of \$${amount} failed.");
    }
  }

  @override
  Future<int> get balance async => _balance;
}

/// Synchronization Proxy for BankAccount
class SynchronizedBankAccountProxy implements BankAccount {
  final RealBankAccount _realAccount = RealBankAccount();
  // final _lock = Object();

  @override
  Future<void> deposit(int amount) async {
    await _synchronized(() async {
      await _realAccount.deposit(amount);
    });
  }

  @override
  Future<void> withdraw(int amount) async {
    await _synchronized(() async {
      await _realAccount.withdraw(amount);
    });
  }

  @override
  Future<int> get balance async {
    int result = 0;
    await _synchronized(() async {
      result = await _realAccount.balance;
    });
    return result;
  }

  Future<void> _synchronized(Future<void> Function() operation) async {
    // Simulate critical section protection
    await Future(() async {
      // print("Entering synchronized block...");
      await operation();
      // print("Exiting synchronized block...");
    });
  }
}

// Step 4: Client Code
// Future<void> main() async {
//   /// Virtual Proxy
//   print("=== Virtual Proxy ===");
//   print("Creating proxy for 'photo1.jpg'...");
//   Image image1 = ImageProxy("photo1.jpg");
//
//   print("\nCreating proxy for 'photo2.jpg'...");
//   Image image2 = ImageProxy("photo2.jpg");
//
//   print("\nDisplaying 'photo1.jpg'...");
//   image1.display(); // Real image is loaded here
//
//   print("\nDisplaying 'photo2.jpg'...");
//   image2.display(); // Real image is loaded here
//
//   print("\nDisplaying 'photo1.jpg' again...");
//   image1.display(); // Real image is reused without loading
//
//   /// Remote Proxy
//   print("\n=== Remote Proxy ===");
//   print("Scenario 1: Unauthenticated user");
//   RemoteService unauthenticatedService = RemoteServiceProxy(isAuthenticated: false);
//   unauthenticatedService.fetchData();
//
//   print("\nScenario 2: Authenticated user");
//   RemoteService authenticatedService = RemoteServiceProxy(isAuthenticated: true);
//   authenticatedService.fetchData();
//
//   /// Protection Proxy
//   print("\n=== Protection Proxy ===");
//   Database dbAdmin = DatabaseProxy("admin");
//   Database dbUser = DatabaseProxy("user");
//
//   dbAdmin.query("DELETE FROM users"); // Allowed
//   dbUser.query("DELETE FROM users"); // Denied
//
//   /// Cache Proxy
//   print("\n=== Cache Proxy ===");
//   WeatherService weatherService = CachedWeatherServiceProxy();
//
//   print(weatherService.getWeather("New York")); // Fetches new data
//   print(weatherService.getWeather("New York")); // Returns cached data
//   print(weatherService.getWeather("Los Angeles")); // Fetches new data
//
//   /// Firewall Proxy
//   print("\n=== Firewall Proxy ===");
//   WebServer server = FirewallProxy();
//
//   server.handleRequest("192.168.1.5"); // Blocked
//   server.handleRequest("192.168.1.10"); // Allowed
//
//   /// Synchronization Proxy
//   print("\n=== Synchronization Proxy: Bank Account ===");
//   BankAccount account = SynchronizedBankAccountProxy();
//
//   // Simulate multiple tasks depositing and withdrawing money
//   List<Future> tasks = [
//     account.deposit(100),
//     account.withdraw(50),
//     account.deposit(200),
//     account.withdraw(150),
//     account.withdraw(200),
//   ];
//
//   print("\nSimulating multiple transactions...");
//   await Future.wait(tasks);
//
//   // Get the final balance
//   int finalBalance = await account.balance;
//   print("\nFinal balance: \$${finalBalance}");
// }

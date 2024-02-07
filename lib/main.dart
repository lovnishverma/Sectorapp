import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lovnish Plots App',
      theme: ThemeData(
        primaryColor: Colors.red,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.red).copyWith(secondary: Colors.white),
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          headline4: TextStyle(color: Colors.red),
          bodyText2: TextStyle(color: Colors.black),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red,
              ),
              child: Text(
                'Lovnish Plots App',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            _buildDrawerTile(
              context,
              title: 'Sector Information',
              page: InfoPage(),
            ),
            _buildDrawerTile(
              context,
              title: 'All Plots',
              page: AllPlotsPage(),
            ), // New tile for All Plots Page
            _buildDrawerTile(
              context,
              title: 'Add Plot',
              page: AddPlotPage(),
            ),
            _buildDrawerTile(
              context,
              title: 'Search Plots',
              page: SearchPlotsPage(),
            ),
            _buildDrawerTile(
              context,
              title: 'Demo Maps',
              page: DemoMapsPage(),
            ),
            _buildDrawerTile(
              context,
              title: 'Latest Updates/Projects',
              page: LatestUpdatesPage(),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            children: [
              _buildHomeTile(
                context,
                title: 'Sector Information',
                page: InfoPage(),
                icon: Icons.info,
              ),
              _buildHomeTile(
                context,
                title: 'All Plots',
                page: AllPlotsPage(),
                icon: Icons.list, // Icon for All Plots Page
              ),
              _buildHomeTile(
                context,
                title: 'Add Plot',
                page: AddPlotPage(),
                icon: Icons.add,
              ),
              _buildHomeTile(
                context,
                title: 'Search Plots',
                page: SearchPlotsPage(),
                icon: Icons.search,
              ),
              _buildHomeTile(
                context,
                title: 'Demo Maps',
                page: DemoMapsPage(),
                icon: Icons.map,
              ),
              _buildHomeTile(
                context,
                title: 'Latest Updates/Projects',
                page: LatestUpdatesPage(),
                icon: Icons.new_releases,
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListTile _buildDrawerTile(BuildContext context, {required String title, required Widget page}) {
    return ListTile(
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }

  Widget _buildHomeTile(BuildContext context, {required String title, required Widget page, required IconData icon}) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 40, color: Colors.red),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OptionTile extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const OptionTile({required this.title, required this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(title),
    );
  }
}

class InfoPage extends StatefulWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  List<String> sectors = [];
  bool isLoading = true;
  List<dynamic> plotsForSelectedSector = [];
  bool isFetchingPlots = false;

  @override
  void initState() {
    super.initState();
    _fetchSectors();
  }

  Future<void> _fetchSectors() async {
    try {
      final response = await http.get(Uri.parse('https://sectorplot.glitch.me/getSectors'));

      if (response.statusCode == 200) {
        setState(() {
          sectors = List<String>.from(jsonDecode(response.body));
          isLoading = false;
        });
      } else {
        print('Failed to fetch sectors. Error: ${response.reasonPhrase}');
        isLoading = false;
      }
    } catch (error) {
      print('Error: $error');
      isLoading = false;
    }
  }

  Future<void> _fetchPlotsForSector(String selectedSector) async {
    setState(() {
      isFetchingPlots = true;
    });

    try {
      final response = await http.get(Uri.parse('https://sectorplot.glitch.me/getPlotsInSector/$selectedSector'));

      if (response.statusCode == 200) {
        setState(() {
          plotsForSelectedSector = jsonDecode(response.body);
        });
      } else {
        print('Failed to fetch plots. Error code: ${response.statusCode}, Reason: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error: $error');
    } finally {
      setState(() {
        isFetchingPlots = false;
      });
    }
  }

  void _onInfoTabPressed(String selectedSector) {
    print('Info Page Clicked');
    _fetchPlotsForSector(selectedSector);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Sector Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (isLoading)
                  CircularProgressIndicator()
                else if (sectors.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: sectors.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text('Sector ${sectors[index]}'),
                          onTap: () => _onInfoTabPressed(sectors[index]),
                        );
                      },
                    ),
                  )
                else
                  const Text('No sectors available'),
                SizedBox(height: 16),
                if (plotsForSelectedSector.isNotEmpty)
                  Column(
                    children: [
                      Text('Plots in Selected Sector:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      for (var plot in plotsForSelectedSector)
                        Card(
                          child: ListTile(
                            title: Text('Seller: ${plot['name']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Mobile Number: ${plot['mobileNumber']}'),
                                Text('Plot: ${plot['plot']}'),
                                Text('Price: ${plot['price']}'),
                                Text('Sector: ${plot['sector']}'),
                              ],
                            ),
                          ),
                        ),
                    ],
                  )
                else if (isFetchingPlots)
                  CircularProgressIndicator()
                else
                  const Text('Select Sector to check available Plots'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AllPlotsPage extends StatefulWidget {
  const AllPlotsPage({Key? key}) : super(key: key);

  @override
  _AllPlotsPageState createState() => _AllPlotsPageState();
}

class _AllPlotsPageState extends State<AllPlotsPage> {
  List<dynamic> allPlots = [];
  bool isLoading = true; // Track whether data is still being loaded

  @override
  void initState() {
    super.initState();
    _fetchAllPlots();
  }

  Future<void> _fetchAllPlots() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('https://sectorplot.glitch.me/getAllPlots'));

      if (response.statusCode == 200) {
        setState(() {
          allPlots = jsonDecode(response.body);
          isLoading = false; // Set loading to false once data is loaded
        });
      } else {
        print('Failed to fetch all plots. Error: ${response.reasonPhrase}');
        isLoading = false; // Set loading to false in case of an error
      }
    } catch (error) {
      print('Error: $error');
      isLoading = false; // Set loading to false in case of an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Plots'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  Text('All Available Plots', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  if (isLoading)
                    CircularProgressIndicator() // Display loading indicator while data is being fetched
                  else if (allPlots.isNotEmpty)
                    Column(
                      children: [
                        Text('Plot Information:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        for (var plot in allPlots)
                          Card(
                            child: ListTile(
                              title: Text('Seller: ${plot['name']}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Mobile Number: ${plot['mobileNumber']}'),
                                  Text('Plot: ${plot['plot']}'),
                                  Text('Price: ${plot['price']}'),
                                  Text('Sector: ${plot['sector']}'),
                                ],
                              ),
                            ),
                          ),
                      ],
                    )
                  else
                    const Text('No plots available'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class AddPlotPage extends StatefulWidget {
  const AddPlotPage({Key? key}) : super(key: key);

  @override
  _AddPlotPageState createState() => _AddPlotPageState();
}

class _AddPlotPageState extends State<AddPlotPage> {
  final TextEditingController sellerNameController = TextEditingController();
  final TextEditingController sellerMobileNumberController = TextEditingController();
  final TextEditingController sellerPlotController = TextEditingController();
  final TextEditingController sellerPriceController = TextEditingController();
  final TextEditingController sellerSectorController = TextEditingController();

  bool isAddingPlot = false; // Track whether adding plot is in progress

  Future<void> _addPlot() async {
    setState(() {
      isAddingPlot = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://sectorplot.glitch.me/addPlot'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'name': sellerNameController.text,
          'mobileNumber': sellerMobileNumberController.text,
          'sector': sellerSectorController.text,
          'plot': sellerPlotController.text,
          'price': double.parse(sellerPriceController.text),
        }),
      );

      if (response.statusCode == 200) {
        print('Plot added successfully');

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Plot added successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        print('Failed to add plot. Error: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error: $error');
    } finally {
      setState(() {
        isAddingPlot = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Plot'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Seller Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: sellerNameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  controller: sellerMobileNumberController,
                  decoration: InputDecoration(labelText: 'Mobile Number'),
                ),
                TextFormField(
                  controller: sellerPlotController,
                  decoration: InputDecoration(labelText: 'Plot'),
                ),
                TextFormField(
                  controller: sellerPriceController,
                  decoration: InputDecoration(labelText: 'Price'),
                ),
                TextFormField(
                  controller: sellerSectorController,
                  decoration: InputDecoration(labelText: 'Sector'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isAddingPlot ? null : () => _addPlot(),
                  child: isAddingPlot
                      ? CircularProgressIndicator() // Show loading indicator
                      : Text('Add Plot'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SearchPlotsPage extends StatefulWidget {
  const SearchPlotsPage({Key? key}) : super(key: key);

  @override
  _SearchPlotsPageState createState() => _SearchPlotsPageState();
}

class _SearchPlotsPageState extends State<SearchPlotsPage> {
  final TextEditingController buyerSectorController = TextEditingController();
  List<dynamic> searchResults = [];
  bool isSearching = false; // Track whether searching is in progress

  Future<void> _searchPlots() async {
    setState(() {
      isSearching = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://sectorplot.glitch.me/searchPlots/${buyerSectorController.text}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          searchResults = jsonDecode(response.body);
        });
        print('Plots found: ${searchResults.length}');
      } else {
        print('Failed to search for plots. Error: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error: $error');
    } finally {
      setState(() {
        isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Plots'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Buyer Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: buyerSectorController,
                  decoration: InputDecoration(labelText: 'Sector'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isSearching ? null : () => _searchPlots(),
                  child: isSearching
                      ? CircularProgressIndicator() // Show loading indicator
                      : Text('Search Plots'),
                ),
                SizedBox(height: 16),
                if (searchResults.isNotEmpty)
                  Column(
                    children: [
                      Text('Search Results:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      for (var result in searchResults)
                        Card(
                          child: ListTile(
                            title: Text('Seller: ${result['name']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Mobile Number: ${result['mobileNumber']}'),
                                Text('Plot: ${result['plot']}'),
                                Text('Sector: ${result['sector']}'),
                                Text('Price: ${result['price']}'),
                              ],
                            ),
                          ),
                        ),
                    ],
                  )
                else
                  const Text('No plots found'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DemoMapsPage extends StatelessWidget {
  final List<String> demoImageUrls = [
    'https://cdn.glitch.global/d4bbe507-1027-4510-8d31-080d135c57d6/chd_map.jpg?v=1706000820836',
    'https://cdn.glitch.global/d4bbe507-1027-4510-8d31-080d135c57d6/download%20(7).jpg?v=1706000826503',
    // Add more demo image URLs as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Maps'),
      ),
      body: PhotoViewGallery.builder(
        itemCount: demoImageUrls.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(demoImageUrls[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.contained * 2,
          );
        },
        scrollPhysics: BouncingScrollPhysics(),
        backgroundDecoration: BoxDecoration(
          color: Colors.white,
        ),
        pageController: PageController(),
      ),
    );
  }
}

class LatestUpdatesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Latest Updates/Projects'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Latest Updates/Projects', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            LatestUpdateCard(
              title: 'New Feature: Real-time Sector Updates',
              description: 'We have added real-time updates for sector information. Now, you can get the latest sector data as soon as it is available.',
              date: 'January 25, 2024',
            ),
            LatestUpdateCard(
              title: 'Improved Search Functionality',
              description: 'Our search functionality has been enhanced to provide faster and more accurate results. Try it out in the "Search Plots" section!',
              date: 'January 24, 2024',
            ),
            // Add more demo data as needed
          ],
        ),
      ),
    );
  }
}

class LatestUpdateCard extends StatelessWidget {
  final String title;
  final String description;
  final String date;

  const LatestUpdateCard({
    required this.title,
    required this.description,
    required this.date,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(description),
            SizedBox(height: 8),
            Text('Date: $date', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
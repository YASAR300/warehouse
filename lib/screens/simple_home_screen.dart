import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/simple_app_state.dart';
import 'simple_container_detail_screen.dart';

/// Simple home screen for container management
class SimpleHomeScreen extends StatefulWidget {
  const SimpleHomeScreen({super.key});

  @override
  State<SimpleHomeScreen> createState() => _SimpleHomeScreenState();
}

class _SimpleHomeScreenState extends State<SimpleHomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: _selectedIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SimpleAppState>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warehouse Container Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              _showInfoDialog();
            },
          ),
        ],
      ),
      body: Consumer<SimpleAppState>(
        builder: (context, appState, child) {
          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search containers...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),

              // Tab bar
              TabBar(
                controller: _tabController,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Active'),
                  Tab(text: 'Completed'),
                ],
              ),

              // Container list
              Expanded(
                child: _buildContainerList(appState),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNewContainerDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Build container list based on selected tab
  Widget _buildContainerList(SimpleAppState appState) {
    List<SimpleContainer> containers;

    switch (_selectedIndex) {
      case 1:
        containers = appState.activeContainers;
        break;
      case 2:
        containers = appState.completedContainers;
        break;
      default:
        containers = appState.containers;
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      containers = containers.where((container) {
        return container.containerNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               container.type.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (container.doorNumber?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    if (containers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedIndex == 0 ? Icons.inventory_2 : 
              _selectedIndex == 1 ? Icons.work : Icons.check_circle,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _selectedIndex == 0 ? 'No containers found' :
              _selectedIndex == 1 ? 'No active containers' : 'No completed containers',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            if (_searchQuery.isNotEmpty)
              const Text(
                'Try adjusting your search terms',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: containers.length,
      itemBuilder: (context, index) {
        final container = containers[index];
        return _buildContainerCard(container);
      },
    );
  }

  /// Build container card widget
  Widget _buildContainerCard(SimpleContainer container) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: container.status == 'Completed' ? Colors.green : Colors.blue,
          child: Icon(
            container.status == 'Completed' ? Icons.check : Icons.inventory_2,
            color: Colors.white,
          ),
        ),
        title: Text(
          container.containerNumber,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${container.type}'),
            if (container.doorNumber != null)
              Text('Door: ${container.doorNumber}'),
            Text(
              'Status: ${container.status}',
              style: TextStyle(
                color: container.status == 'Completed' ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (container.discrepancies.isNotEmpty)
              const Text(
                '⚠️ Has Discrepancies',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SimpleContainerDetailScreen(
                  container: container,
                ),
              ),
            );
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SimpleContainerDetailScreen(
                container: container,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Show new container dialog
  void _showNewContainerDialog(BuildContext context) {
    final containerController = TextEditingController();
    String selectedType = 'Import';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('New Container'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: containerController,
                decoration: const InputDecoration(
                  labelText: 'Container Number',
                  hintText: 'Enter container number',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                ),
                items: ['Import', 'Export', 'Delivery'].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedType = value;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final containerNumber = containerController.text.trim();
                if (containerNumber.isNotEmpty) {
                  context.read<SimpleAppState>().createNewContainer(
                    containerNumber,
                    selectedType,
                  );
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SimpleContainerDetailScreen(
                        container: context.read<SimpleAppState>().currentContainer!,
                      ),
                    ),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  /// Show info dialog
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warehouse Container Tracker'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('A simple Flutter app for tracking warehouse containers.'),
            SizedBox(height: 8),
            Text('Features:'),
            Text('• Add/Edit containers'),
            Text('• Track piece counts'),
            Text('• Record materials'),
            Text('• Note discrepancies'),
            Text('• Manage door assignments'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

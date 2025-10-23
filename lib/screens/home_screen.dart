import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/container_model.dart';
import 'container_detail_screen.dart';
import 'settings_screen.dart';

/// Home screen displaying list of containers
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: _selectedIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().initialize();
      context.read<AppState>().loadContainers();
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
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

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

              // Offline indicator
              if (appState.isOffline)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  color: Colors.orange,
                  child: const Text(
                    'OFFLINE MODE - Data will sync when online',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              // Offline queue indicator
              if (appState.offlineQueue.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  color: Colors.blue,
                  child: Text(
                    '${appState.offlineQueue.length} containers pending sync',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
  Widget _buildContainerList(AppState appState) {
    List<ContainerModel> containers;

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
               container.type.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
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
  Widget _buildContainerCard(ContainerModel container) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: container.isCompleted ? Colors.green : Colors.blue,
          child: Icon(
            container.isCompleted ? Icons.check : Icons.inventory_2,
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
            Text('Type: ${container.type.displayName}'),
            if (container.doorNumber != null)
              Text('Door: ${container.doorNumber}'),
            if (container.isCompleted && container.completedAt != null)
              Text(
                'Completed: ${_formatDate(container.completedAt!)}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (container.hasDiscrepancies)
              const Text(
                '⚠️ Has Discrepancies',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (container.shareableLink != null)
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  _showShareableLinkDialog(container);
                },
              ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContainerDetailScreen(
                      container: container,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContainerDetailScreen(
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
    ContainerType selectedType = ContainerType.import;

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
              DropdownButtonFormField<ContainerType>(
                initialValue: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                ),
                items: ContainerType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
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
                  context.read<AppState>().createNewContainer(
                    containerNumber,
                    selectedType,
                  );
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContainerDetailScreen(
                        container: context.read<AppState>().currentContainer!,
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

  /// Show shareable link dialog
  void _showShareableLinkDialog(ContainerModel container) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Shareable Link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Container files are available at:'),
            const SizedBox(height: 8),
            SelectableText(
              container.shareableLink ?? 'No link available',
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
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

  /// Format date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

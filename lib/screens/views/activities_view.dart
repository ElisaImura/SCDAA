import 'package:flutter/material.dart';

class ActivitiesView extends StatefulWidget {
  @override
  _ActivitiesViewState createState() => _ActivitiesViewState();
}

class _ActivitiesViewState extends State<ActivitiesView> {
  String statusFilter = 'Pendientes';
  String userFilter = 'Todos';
  String activityTypeFilter = 'Todos';
  String cycleFilter = 'Todos';
  String lotFilter = 'Todos';
  String cropTypeFilter = 'Todos';
  String varietyTypeFilter = 'Todos';
  DateTimeRange dateRangeFilter = DateTimeRange(start: DateTime.now(), end: DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Actividades'),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _buildActivitiesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        DropdownButton<String>(
          value: statusFilter,
          onChanged: (String? newValue) {
            setState(() {
              statusFilter = newValue!;
            });
          },
          items: <String>['Pendientes', 'En progreso', 'Terminados']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        // Add more DropdownButton widgets for other filters (userFilter, activityTypeFilter, etc.)
        // ...existing code...
      ],
    );
  }

  Widget _buildActivitiesList() {
    // Replace with actual data fetching and filtering logic
    List<String> activities = ['Actividad 1', 'Actividad 2', 'Actividad 3'];

    return ListView.builder(
      itemCount: activities.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(activities[index]),
        );
      },
    );
  }
}

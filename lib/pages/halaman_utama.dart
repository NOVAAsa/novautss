import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _routeController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  List<Map<String, dynamic>> _items = [];
  static const _prefsKey = 'rides';
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey);
    if (raw != null) {
      setState(() {
        _items = raw.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
      });
    }
  }

  Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = _items.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList(_prefsKey, raw);
  }

  void _addOrUpdateItem() {
    final day = _dayController.text.trim();
    final time = _timeController.text.trim();
    final route = _routeController.text.trim();
    final distance = double.tryParse(_distanceController.text) ?? 0.0;
    final duration = int.tryParse(_durationController.text) ?? 0;

    if (day.isEmpty || route.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hari dan Route wajib diisi')));
      return;
    }

    final newItem = {
      'day': day,
      'time': time,
      'route': route,
      'distance': distance,
      'duration': duration,
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    if (_editingIndex == null) {
      setState(() => _items.insert(0, newItem));
    } else {
      setState(() {
        _items[_editingIndex!] = newItem;
        _editingIndex = null;
      });
    }

    _saveAll();
    _clearForm();
  }

  void _clearForm() {
    _dayController.clear();
    _timeController.clear();
    _routeController.clear();
    _distanceController.clear();
    _durationController.clear();
    setState(() => _editingIndex = null);
  }

  void _startEdit(int index) {
    final item = _items[index];
    _dayController.text = item['day'];
    _timeController.text = item['time'];
    _routeController.text = item['route'];
    _distanceController.text = item['distance'].toString();
    _durationController.text = item['duration'].toString();
    setState(() => _editingIndex = index);
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
    _saveAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Jadwal Sepeda')),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            TextField(controller: _dayController, decoration: const InputDecoration(labelText: 'Hari')),
            TextField(controller: _timeController, decoration: const InputDecoration(labelText: 'Jam')),
            TextField(controller: _routeController, decoration: const InputDecoration(labelText: 'Rute')),
            TextField(controller: _distanceController, decoration: const InputDecoration(labelText: 'Jarak (km)')),
            TextField(controller: _durationController, decoration: const InputDecoration(labelText: 'Durasi (menit)')),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addOrUpdateItem,
                    child: Text(_editingIndex == null ? 'Tambah' : 'Update'),
                  ),
                ),
                if (_editingIndex != null) ...[
                  const SizedBox(width: 8),
                  TextButton(onPressed: _clearForm, child: const Text('Batal'))
                ]
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _items.isEmpty
                  ? const Center(child: Text('Belum ada data'))
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Dismissible(
                          key: Key(item['id']),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            color: Colors.red,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) => _removeItem(index),
                          child: ListTile(
                            title: Text('${item['day']} - ${item['route']}'),
                            subtitle: Text('Jarak: ${item['distance']} km, Durasi: ${item['duration']} menit'),
                            onTap: () => _startEdit(index),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'halaman_utama.dart';
import '../models/ride.dart';
import 'dart:math' as math;

class DashboardPage extends StatefulWidget {
  final String loggedUser;
  const DashboardPage({super.key, required this.loggedUser});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<Ride> _rides = [];

  String _genId() => DateTime.now().millisecondsSinceEpoch.toString() + math.Random().nextInt(999).toString();

  double get _totalKm => _rides.fold(0.0, (p, e) => p + e.distanceKm);
  Duration get _totalDuration => _rides.fold(Duration.zero, (p, e) => p + e.duration);

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return '${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')}';
  }

  Duration? _parseDuration(String s) {
    final parts = s.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return Duration(hours: h, minutes: m);
  }

  // FORM ADD / EDIT
  Future<void> _openAddEditSheet({Ride? editRide}) async {
    final isEdit = editRide != null;
    final dayCtrl = TextEditingController(text: editRide?.day ?? '');
    final timeCtrl = TextEditingController(text: editRide?.time ?? '');
    final routeCtrl = TextEditingController(text: editRide?.route ?? '');
    final distanceCtrl = TextEditingController(text: editRide?.distanceKm.toString() ?? '');
    final durationCtrl = TextEditingController(text: editRide != null ? _formatDuration(editRide.duration) : '01:00');

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(height: 4, width: 40, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 15),
                  Text(isEdit ? 'Edit Jadwal Bersepeda' : 'Tambah Jadwal Bersepeda', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 18),
                  _input(dayCtrl, "Hari"),
                  const SizedBox(height: 12),
                  _input(timeCtrl, "Waktu"),
                  const SizedBox(height: 12),
                  _input(routeCtrl, "Rute Bersepeda"),
                  const SizedBox(height: 12),
                  _input(distanceCtrl, "Jarak Tempuh (KM)", type: TextInputType.number),
                  const SizedBox(height: 12),
                  _input(durationCtrl, "Durasi (Format: 01:30)"),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final day = dayCtrl.text.trim();
                        final time = timeCtrl.text.trim();
                        final route = routeCtrl.text.trim();
                        final distance = double.tryParse(distanceCtrl.text.trim()) ?? -1.0;
                        final duration = _parseDuration(durationCtrl.text.trim());

                        if (day.isEmpty || time.isEmpty || route.isEmpty || distance <= 0 || duration == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Isi data dengan benar")));
                          return;
                        }

                        setState(() {
                          if (isEdit) {
                            editRide!.day = day;
                            editRide.time = time;
                            editRide.route = route;
                            editRide.distanceKm = distance;
                            editRide.duration = duration;
                          } else {
                            _rides.insert(0, Ride(id: _genId(), day: day, time: time, route: route, distanceKm: distance, duration: duration));
                          }
                        });

                        Navigator.pop(ctx);
                      },
                      child: Text(isEdit ? "Simpan Perubahan" : "Tambah Jadwal"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _input(TextEditingController c, String label, {TextInputType type = TextInputType.text}) {
    return TextField(controller: c, keyboardType: type, decoration: InputDecoration(labelText: label, filled: true, fillColor: Colors.blue.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)));
  }

  void _onMenuTap(int idx) {
    if (idx == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
    } else if (idx == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const HalamanUtama()));
    } else if (idx == 2) {
      showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Pengaturan'), content: const Text('Fitur belum tersedia'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tutup"))]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Bersepeda'), backgroundColor: Colors.blueAccent),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () => _openAddEditSheet(),
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 32, backgroundImage: AssetImage('assets/images/NOVA.jpg')),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Halo, ${widget.loggedUser}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                          Text("${_rides.length} Jadwal Bersepeda"),
                          Text("${_totalKm.toStringAsFixed(1)} km • ${_formatDuration(_totalDuration)}"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.90,
              children: [
                _menuTile(Icons.person, 'Profil', 0),
                _menuTile(Icons.list_alt, 'Form Data', 1),
                _menuTile(Icons.settings, 'Pengaturan', 2),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              itemCount: _rides.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (ctx, i) {
                final r = _rides[i];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    leading: const Icon(Icons.directions_bike, color: Colors.blue),
                    title: Text("${r.day}, ${r.time}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${r.route}\n${r.distanceKm.toStringAsFixed(1)} km • ${_formatDuration(r.duration)}"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuTile(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () => _onMenuTap(index),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 22, backgroundColor: Colors.blue.shade100, child: Icon(icon, color: Colors.purple)),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'dart:math' as math;

/// Model Jadwal Bersepeda
class Ride {
  String id;
  String day;
  String time;
  String route;
  double distanceKm;
  Duration duration;

  Ride({
    required this.id,
    required this.day,
    required this.time,
    required this.route,
    required this.distanceKm,
    required this.duration,
  });
}

class DashboardPage extends StatefulWidget {
  final String loggedUser;
  const DashboardPage({super.key, required this.loggedUser});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<Ride> _rides = [
    Ride(
      id: 'r1',
      day: 'Rabu',
      time: '06:00',
      route: 'Tugu Muda → Kota Lama → Sam Poo Kong',
      distanceKm: 12.5,
      duration: const Duration(hours: 1, minutes: 10),
    ),
    Ride(
      id: 'r2',
      day: 'Sabtu',
      time: '05:30',
      route: 'Kampus → Tugu Muda → Lawang Sewu',
      distanceKm: 18.0,
      duration: const Duration(hours: 1, minutes: 45),
    ),
  ];

  String _genId() => DateTime.now().millisecondsSinceEpoch.toString() + math.Random().nextInt(999).toString();

  double get _totalKm => _rides.fold(0.0, (p, e) => p + e.distanceKm);
  Duration get _totalDuration => _rides.fold(Duration.zero, (p, e) => p + e.duration);

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  Duration? _parseDuration(String s) {
    final parts = s.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return Duration(hours: h, minutes: m);
  }

  // Add / Edit bottom sheet
  Future<void> _openAddEditSheet({Ride? editRide}) async {
    final isEdit = editRide != null;
    final dayCtrl = TextEditingController(text: editRide?.day ?? '');
    final timeCtrl = TextEditingController(text: editRide?.time ?? '');
    final routeCtrl = TextEditingController(text: editRide?.route ?? '');
    final distanceCtrl = TextEditingController(text: editRide != null ? editRide.distanceKm.toString() : '');
    final durationCtrl = TextEditingController(text: editRide != null ? _formatDuration(editRide.duration) : '01:00');

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: StatefulBuilder(builder: (contextSB, setStateSB) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(
                    children: [
                      Expanded(child: Text(isEdit ? 'Edit Jadwal' : 'Tambah Jadwal', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(ctx).pop()),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(controller: dayCtrl, decoration: const InputDecoration(labelText: 'Hari (contoh: Rabu)')),
                  const SizedBox(height: 8),
                  TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'Waktu (HH:MM)')),
                  const SizedBox(height: 8),
                  TextField(controller: routeCtrl, decoration: const InputDecoration(labelText: 'Rute')),
                  const SizedBox(height: 8),
                  TextField(controller: distanceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Jarak (km)')),
                  const SizedBox(height: 8),
                  TextField(controller: durationCtrl, decoration: const InputDecoration(labelText: 'Durasi (HH:MM)')),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final day = dayCtrl.text.trim();
                          final time = timeCtrl.text.trim();
                          final route = routeCtrl.text.trim();
                          final distance = double.tryParse(distanceCtrl.text.trim()) ?? -1.0;
                          final duration = _parseDuration(durationCtrl.text.trim());

                          if (day.isEmpty || time.isEmpty || route.isEmpty || distance <= 0 || duration == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Isi semua field dengan benar (jarak > 0, durasi HH:MM)')));
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
                              final newRide = Ride(
                                id: _genId(),
                                day: day,
                                time: time,
                                route: route,
                                distanceKm: distance,
                                duration: duration,
                              );
                              _rides.insert(0, newRide);
                            }
                          });

                          Navigator.of(ctx).pop();
                        },
                        child: Text(isEdit ? 'Simpan' : 'Tambah'),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                ]),
              ),
            );
          }),
        );
      },
    );
  }

  void _confirmDelete(Ride ride) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Jadwal'),
        content: const Text('Yakin ingin menghapus jadwal ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => _rides.removeWhere((r) => r.id == ride.id));
              Navigator.of(ctx).pop();
            },
            child: const Text('Hapus'),
          )
        ],
      ),
    );
  }

  void _showDetail(Ride ride) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.directions_bike, size: 36),
            title: Text('${ride.day} • ${ride.time}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(ride.route),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: Text('Jarak: ${ride.distanceKm.toStringAsFixed(1)} km')),
            Expanded(child: Text('Durasi: ${_formatDuration(ride.duration)}')),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            ElevatedButton.icon(onPressed: () { Navigator.of(ctx).pop(); _openAddEditSheet(editRide: ride); }, icon: const Icon(Icons.edit), label: const Text('Edit')),
            const SizedBox(width: 8),
            ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () { Navigator.of(ctx).pop(); _confirmDelete(ride); }, icon: const Icon(Icons.delete), label: const Text('Hapus')),
            const SizedBox(width: 8),
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Tutup')),
          ]),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  // MENU ACTIONS
  void _onMenuTap(int idx) {
    if (idx == 0) {
      // Profil
      Navigator.push(context, MaterialPageRoute(builder: (c) => const ProfilePage()));
    } else if (idx == 1) {
      // Data -> show simple dialog (placeholder)
      showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Data'), content: const Text('Fitur Data belum diimplementasi (placeholder).'), actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Tutup'))]));
    } else if (idx == 2) {
      // Pengaturan -> show simple dialog
      showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Pengaturan'), content: const Text('Fitur Pengaturan belum diimplementasi (placeholder).'), actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Tutup'))]));
    }
  }

  @override
  Widget build(BuildContext context) {
    const radius = 12.0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Bersepeda Semarang'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // contoh: tampilkan snackbar
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak ada notifikasi baru')));
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddEditSheet(),
        child: const Icon(Icons.add),
        tooltip: 'Tambah Jadwal',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // banner
            ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Image.asset('assets/images/SEPEDA2.jpg', width: double.infinity, height: 140, fit: BoxFit.cover),
            ),
            const SizedBox(height: 12),

            // header card (avatar + greeting + stats)
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(children: [
                  CircleAvatar(radius: 36, backgroundImage: const AssetImage('assets/images/NOVA.jpg')),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Halo, ${widget.loggedUser}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 6),
                      Text('${_rides.length} jadwal • Total ${_totalKm.toStringAsFixed(1)} km'),
                      const SizedBox(height: 6),
                      Text('Durasi total: ${_formatDuration(_totalDuration)}'),
                    ]),
                  ),
                  ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/images/SEPEDA.jpg', width: 64, height: 64, fit: BoxFit.cover)),
                ]),
              ),
            ),
            const SizedBox(height: 12),

            // menu grid (3 item)
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              shrinkWrap: true,
              childAspectRatio: 0.85,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _menuTile(Icons.person, 'Profil', 0),
                _menuTile(Icons.list, 'Data', 1),
                _menuTile(Icons.settings, 'Pengaturan', 2),
              ],
            ),
            const SizedBox(height: 12),

            // statistik mini
            Row(children: [
              Expanded(child: _statCard('Total KM', '${_totalKm.toStringAsFixed(1)} km', Icons.straighten)),
              const SizedBox(width: 8),
              Expanded(child: _statCard('Total Waktu', _formatDuration(_totalDuration), Icons.timer)),
              const SizedBox(width: 8),
              Expanded(child: _statCard('Jadwal', '${_rides.length}', Icons.calendar_month)),
            ]),
            const SizedBox(height: 12),

            // title + add button
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Daftar Jadwal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton.icon(onPressed: () => _openAddEditSheet(), icon: const Icon(Icons.add), label: const Text('Tambah')),
            ]),
            const SizedBox(height: 8),

            // list jadwal
            ListView.builder(
              itemCount: _rides.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (ctx, i) {
                final r = _rides[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.directions_bike),
                    title: Text('${r.day} • ${r.time}'),
                    subtitle: Text('${r.route}\n${r.distanceKm.toStringAsFixed(1)} km • ${_formatDuration(r.duration)}',
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    isThreeLine: true,
                    onTap: () => _showDetail(r),
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'detail') _showDetail(r);
                        if (v == 'edit') _openAddEditSheet(editRide: r);
                        if (v == 'delete') _confirmDelete(r);
                      },
                      itemBuilder: (c) => const [
                        PopupMenuItem(value: 'detail', child: Text('Detail')),
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Hapus')),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuTile(IconData icon, String label, int idx) {
    return GestureDetector(
      onTap: () => _onMenuTap(idx),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            CircleAvatar(radius: 22, backgroundColor: const Color.fromARGB(255, 219, 114, 186), child: Icon(icon, color: Colors.green[900])),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12)),
          ]),
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10),
        child: Row(children: [
          Icon(icon, size: 28),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ])),
        ]),
      ),
    );
  }
}

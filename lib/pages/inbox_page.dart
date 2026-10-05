import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        title: const Text(
          'Inbox',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.indigo, // Warna teks tab aktif
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: Colors.indigo,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 15,
          ),
          tabs: const [
            Tab(text: 'Notifikasi'),
            Tab(text: 'Butuh persetujuan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationTab(),
          _buildApprovalTab(),
        ],
      ),
    );
  }

  // 1. TAB NOTIFIKASI
  Widget _buildNotificationTab() {
    // Data Dummy Notifikasi Pengajuan Cuti / Absensi
    final List<Map<String, String>> notifications = [
      {
        'sender': 'I Gusti Ngurah dummy Adi Wiyusa',
        'description': 'Pengajuan cuti tahunan Anda telah disetujui.',
        'type': 'Leave Request Approved',
        'avatar': 'https://i.pravatar.cc/150?img=11',
      },
      {
        'sender': 'Admin dummy System',
        'description': 'Pengajuan cuti Anda berhasil dikirim dan menunggu persetujuan.',
        'type': 'Leave Request Submitted',
        'avatar': '',
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = notifications[index];
        final bool isSystem = item['avatar']!.isEmpty;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          leading: isSystem
              ? Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.circle_notifications, color: Colors.white),
                )
              : CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(item['avatar']!),
                ),
          title: Text(
            item['sender']!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                item['description']!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item['type']!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          onTap: () {
            // Event ketika item notifikasi diklik
          },
        );
      },
    );
  }

  // 2. TAB BUTUH PERSETUJUAN (Fokus Cuti)
  Widget _buildApprovalTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: Colors.blue,
              size: 22,
            ),
          ),
          title: const Text(
            'Cuti',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          onTap: () {
            // Arahkan ke daftar rincian persetujuan cuti jika ada
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tidak ada pengajuan cuti yang membutuhkan persetujuan Anda.')),
            );
          },
        ),
      ],
    );
  }
}
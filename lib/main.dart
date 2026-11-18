
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// SUPABASE CONFIGURATION
const String supabaseUrl =
    'https://hkpnmfytzrkpjfsxvfqj.supabase.co';

const String supabaseAnonKey =
    'sb_publishable_4pexFqGyx6j09Q788lkypA_6CGo3eJZ';

// YOUR ADMIN USER UID
const String adminUserId =
    'c6dbe6f6-d7ea-4d33-a932-823e0444eada';

final db = Supabase.instance.client;

// COLORS
const bgColor = Color(0xFF070A1F);
const cardColor = Color(0xFF111631);
const purple = Color(0xFF9B5CFF);
const pink = Color(0xFFFF5FB0);
const muted = Color(0xFFA9AED0);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const MarinaApp());
}

class MarinaApp extends StatelessWidget {
  const MarinaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sovann Marina Portfolio',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: purple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const PortfolioPage(),
    );
  }
}

// DEFAULT PORTFOLIO CONTENT
final Map<String, dynamic> defaults = {
  'hero': {
    'name': 'SOVANN MARINA',
    'headline': 'Graphic Designer & IT Network Support',
    'intro':
        'Creative designer and IT professional passionate about technology, design and problem solving.',
    'email': 'sovannmarina168@gmail.com',
    'location': 'Poipet, Banteay Meanchey, Cambodia',
    'telegram': 'https://t.me/RinaDev12',
  },
  'about': {
    'title': 'About Me',
    'body':
        'I am an IT graduate from Build Bright University (2023–2026). I have experience in graphic design, computer teaching and IT network support. I enjoy learning new technologies and solving technical problems.',
  },
  'experience': {
    'title': 'My Experience',
    'items': [
      {
        'role': 'IT Network Support',
        'company': 'Logic Square Building',
        'period': '2024–2026',
        'description':
            'Managed bandwidth, MikroTik and Huawei devices, printers, computers, Wi-Fi and POS systems.',
      },
      {
        'role': 'Computer Teacher & Graphic Designer',
        'company': 'Three Language School',
        'period': '2023–2024',
        'description':
            'Created posters and banners, taught computer applications and supported web research.',
      },
      {
        'role': 'Intern Graphic Designer',
        'company': 'Love Without Boundaries School',
        'period': '2023',
        'description':
            'Completed a three-month internship creating posters and banners using Photoshop and Canva.',
      },
    ],
  },
  'skills': {
    'title': 'My Skills',
    'items': [
      'Graphic Design',
      'Website Development',
      'Network Support',
      'Database',
      'Basic Programming',
      'System Administration',
      'Teamwork',
      'Communication',
      'Time Management',
    ],
  },
  'education': {
    'title': 'Education',
    'items': [
      {
        'school': 'Build Bright University',
        'course': 'Information Technology',
        'period': '2023–2026',
      },
      {
        'school': 'Don Bosco Poipet',
        'course': 'Technical High School',
        'period': '2020–2023',
      },
    ],
  },
  'contact': {
    'title': 'Contact Me',
    'email': 'sovannmarina168@gmail.com',
    'location': 'Poipet, Banteay Meanchey, Cambodia',
    'telegram': 'https://t.me/RinaDev12',
    'message': 'Have a project or opportunity? Let’s talk!',
  },
};

// PORTFOLIO HOME PAGE
class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  Map<String, dynamic> content = {};
  List<Map<String, dynamic>> items = [];
  bool loading = true;
  String? error;

  bool get isAdmin =>
      db.auth.currentUser?.id == adminUserId;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final rows = await db
          .from('portfolio_content')
          .select('section, content');

      final loaded = <String, dynamic>{};

      for (final row in rows) {
        loaded[row['section'].toString()] = row['content'];
      }

      final itemRows = await db
          .from('portfolio_items')
          .select()
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        content = loaded;
        items = itemRows
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        content = {};
        items = [];
        loading = false;
        error = e.toString();
      });
    }
  }

  Map<String, dynamic> getSection(String key) {
    final value = content[key];

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return Map<String, dynamic>.from(defaults[key]);
  }

  List<Map<String, dynamic>> getMapList(dynamic value) {
    if (value is! List) return [];

    return value
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  List<String> getStringList(dynamic value) {
    if (value is! List) return [];
    return value.map((e) => e.toString()).toList();
  }

  Future<void> openAdmin() async {
    if (isAdmin) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AdminPage(),
        ),
      );
      await loadData();
      return;
    }

    final email = TextEditingController();
    final password = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool busy = false;
        String? message;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: cardColor,
              title: const Text('Admin Login'),
              content: SizedBox(
                width: 380,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: email,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: password,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        message!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: busy
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: busy
                      ? null
                      : () async {
                          setDialogState(() => busy = true);

                          try {
                            await db.auth.signInWithPassword(
                              email: email.text.trim(),
                              password: password.text,
                            );

                            if (db.auth.currentUser?.id != adminUserId) {
                              await db.auth.signOut();
                              throw Exception(
                                'This account is not the Admin account.',
                              );
                            }

                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }

                            if (mounted) {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AdminPage(),
                                ),
                              );
                              await loadData();
                            }
                          } catch (e) {
                            setDialogState(() {
                              message = e.toString();
                              busy = false;
                            });
                          }
                        },
                  child: Text(busy ? 'Please wait...' : 'Login'),
                ),
              ],
            );
          },
        );
      },
    );

    email.dispose();
    password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hero = getSection('hero');
    final about = getSection('about');
    final experience = getSection('experience');
    final skills = getSection('skills');
    final education = getSection('education');
    final contact = getSection('contact');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        title: const Text(
          'MARINA.',
          style: TextStyle(
            color: pink,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            onPressed: loadData,
            icon: const Icon(Icons.refresh),
          ),
          TextButton.icon(
            onPressed: openAdmin,
            icon: const Icon(Icons.admin_panel_settings),
            label: const Text('Admin'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: purple),
            )
          : RefreshIndicator(
              onRefresh: loadData,
              child: ListView(
                padding: const EdgeInsets.all(22),
                children: [
                  if (error != null)
                    _Banner(text: 'Database error: $error'),

                  _Hero(
                    name: '${hero['name']}',
                    headline: '${hero['headline']}',
                    intro: '${hero['intro']}',
                  ),

                  _Heading(title: '${about['title']}'),
                  _Card(
                    child: Text(
                      '${about['body']}',
                      style: const TextStyle(
                        color: muted,
                        height: 1.8,
                      ),
                    ),
                  ),

                  _Heading(title: '${experience['title']}'),
                  ...getMapList(experience['items']).map(
                    (e) => _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${e['role']}',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${e['company']} • ${e['period']}',
                            style: const TextStyle(color: pink),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${e['description']}',
                            style: const TextStyle(
                              color: muted,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  _Heading(title: '${skills['title']}'),
                  _Card(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: getStringList(skills['items'])
                          .map(
                            (e) => Chip(
                              label: Text(e),
                              backgroundColor: purple.withOpacity(.2),
                            ),
                          )
                          .toList(),
                    ),
                  ),

                  const _Heading(title: 'Projects & Certificates'),
                  if (items.isEmpty)
                    const _Card(
                      child: Text(
                        'Your projects and certificates will appear here.',
                        style: TextStyle(color: muted),
                      ),
                    ),
                  ...items.map((item) => _ItemCard(item: item)),

                  _Heading(title: '${education['title']}'),
                  ...getMapList(education['items']).map(
                    (e) => _Card(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.school,
                          color: purple,
                        ),
                        title: Text('${e['school']}'),
                        subtitle: Text('${e['course']}'),
                        trailing: Text(
                          '${e['period']}',
                          style: const TextStyle(color: pink),
                        ),
                      ),
                    ),
                  ),

                  _Heading(title: '${contact['title']}'),
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${contact['message']}',
                          style: const TextStyle(color: muted),
                        ),
                        const SizedBox(height: 14),
                        _Contact(
                          icon: Icons.email_outlined,
                          text: '${contact['email']}',
                        ),
                        _Contact(
                          icon: Icons.location_on_outlined,
                          text: '${contact['location']}',
                        ),
                        _Contact(
                          icon: Icons.send_outlined,
                          text: '${contact['telegram']}',
                          link: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Center(
                    child: Text(
                      '© 2026 SOVANN MARINA',
                      style: TextStyle(color: muted),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// HERO
class _Hero extends StatelessWidget {
  final String name;
  final String headline;
  final String intro;

  const _Hero({
    required this.name,
    required this.headline,
    required this.intro,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 45),
      child: Column(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [purple, pink],
              ),
            ),
            child: const Icon(
              Icons.person,
              size: 65,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 25),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            headline,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: pink,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 15),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Text(
              intro,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: muted,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// SECTION HEADING
class _Heading extends StatelessWidget {
  final String title;

  const _Heading({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 14),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// CARD
class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(.07),
        ),
      ),
      child: child,
    );
  }
}

// ERROR BANNER
class _Banner extends StatelessWidget {
  final String text;

  const _Banner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.orangeAccent),
      ),
    );
  }
}

// PORTFOLIO ITEM
class _ItemCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final image = '${item['image_url'] ?? ''}';

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (image.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                image,
                width: double.infinity,
                height: 190,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const SizedBox(height: 50),
              ),
            ),
          const SizedBox(height: 10),
          Text(
            '${item['title']}',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${item['kind']}'.toUpperCase(),
            style: const TextStyle(color: pink),
          ),
          const SizedBox(height: 8),
          Text(
            '${item['description'] ?? ''}',
            style: const TextStyle(color: muted),
          ),
        ],
      ),
    );
  }
}

// CONTACT
class _Contact extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool link;

  const _Contact({
    required this.icon,
    required this.text,
    this.link = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, color: purple),
          const SizedBox(width: 12),
          Expanded(
            child: link
                ? InkWell(
                    onTap: () async {
                      final uri = Uri.tryParse(text);
                      if (uri != null) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    child: Text(
                      text,
                      style: const TextStyle(color: pink),
                    ),
                  )
                : SelectableText(text),
          ),
        ],
      ),
    );
  }
}

// ADMIN DASHBOARD
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  void message(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Future<void> loadItems() async {
    try {
      final rows = await db
          .from('portfolio_items')
          .select()
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        items = rows
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      });
    } catch (e) {
      message('Load error: $e');
    }
  }

  Future<void> editSection(String key) async {
    try {
      final result = await db
          .from('portfolio_content')
          .select('content')
          .eq('section', key)
          .maybeSingle();

      final initial = result?['content'] ?? defaults[key];

      final controller = TextEditingController(
        text: const JsonEncoder.withIndent('  ').convert(initial),
      );

      final save = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: cardColor,
          title: Text('Edit ${key.toUpperCase()}'),
          content: SizedBox(
            width: 650,
            child: TextField(
              controller: controller,
              minLines: 12,
              maxLines: 20,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
              ),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Edit JSON here',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: const Text('Save'),
            ),
          ],
        ),
      );

      if (save == true) {
        final decoded = jsonDecode(controller.text);

        if (decoded is! Map<String, dynamic>) {
          throw const FormatException(
            'JSON must be an object.',
          );
        }

        await db.from('portfolio_content').upsert(
          {
            'section': key,
            'content': decoded,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          },
          onConflict: 'section',
        );

        message('Updated successfully!');
      }

      controller.dispose();
    } catch (e) {
      message('Update failed: $e');
    }
  }

  Future<void> itemForm({Map<String, dynamic>? item}) async {
    final title = TextEditingController(
      text: '${item?['title'] ?? ''}',
    );
    final description = TextEditingController(
      text: '${item?['description'] ?? ''}',
    );
    final image = TextEditingController(
      text: '${item?['image_url'] ?? ''}',
    );

    String kind = '${item?['kind'] ?? 'project'}';

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: cardColor,
            title: Text(item == null ? 'Add Item' : 'Edit Item'),
            content: SizedBox(
              width: 450,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: kind,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'project',
                          child: Text('Project'),
                        ),
                        DropdownMenuItem(
                          value: 'certificate',
                          child: Text('Certificate'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => kind = value);
                        }
                      },
                    ),
                    TextField(
                      controller: title,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                      ),
                    ),
                    TextField(
                      controller: description,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    TextField(
                      controller: image,
                      decoration: const InputDecoration(
                        labelText: 'Image URL',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.pop(dialogContext, true),
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );

    if (saved == true) {
      try {
        if (title.text.trim().isEmpty) {
          throw Exception('Title is required.');
        }

        final data = {
          'kind': kind,
          'title': title.text.trim(),
          'description': description.text.trim(),
          'image_url':
              image.text.trim().isEmpty ? null : image.text.trim(),
        };

        if (item == null) {
          await db.from('portfolio_items').insert(data);
        } else {
          await db
              .from('portfolio_items')
              .update(data)
              .eq('id', item['id']);
        }

        message('Item saved successfully!');
        await loadItems();
      } catch (e) {
        message('Save failed: $e');
      }
    }

    title.dispose();
    description.dispose();
    image.dispose();
  }

  Future<void> deleteItem(Map<String, dynamic> item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: cardColor,
        title: const Text('Delete item?'),
        content: Text('Delete ${item['title']}?'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await db
            .from('portfolio_items')
            .delete()
            .eq('id', item['id']);

        message('Deleted successfully!');
        await loadItems();
      } catch (e) {
        message('Delete failed: $e');
      }
    }
  }

  Future<void> logout() async {
    await db.auth.signOut();

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (db.auth.currentUser?.id != adminUserId) {
      return const Scaffold(
        body: Center(
          child: Text('Unauthorized Admin'),
        ),
      );
    }

    const sections = [
      'hero',
      'about',
      'experience',
      'skills',
      'education',
      'contact',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Manage Portfolio Content',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select a section to edit its information.',
            style: TextStyle(color: muted),
          ),
          const SizedBox(height: 15),

          ...sections.map(
            (key) => Card(
              color: cardColor,
              child: ListTile(
                leading: const Icon(
                  Icons.edit_note,
                  color: purple,
                ),
                title: Text(key.toUpperCase()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => editSection(key),
              ),
            ),
          ),

          const SizedBox(height: 25),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Projects & Certificates',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () => itemForm(),
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ...items.map(
            (item) => Card(
              color: cardColor,
              child: ListTile(
                title: Text('${item['title']}'),
                subtitle: Text('${item['kind']}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      itemForm(item: item);
                    } else if (value == 'delete') {
                      deleteItem(item);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

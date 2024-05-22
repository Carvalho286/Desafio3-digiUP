import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:desafio3/controllers/CRUDservices.dart';
import 'package:desafio3/pages/add_contact_page.dart';
import 'package:desafio3/pages/auth_page.dart';
import 'package:desafio3/pages/update_contact_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'controllers/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MaterialApp(
    home: AuthPage(),
  ));
}

class ContactsList extends StatefulWidget {
  const ContactsList({super.key});

  @override
  State<ContactsList> createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {
  final user = FirebaseAuth.instance.currentUser!;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  late Stream<QuerySnapshot> _stream;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  void _unfocusTextField() {
    if (!_searchFocusNode.hasFocus) {
      return;
    }
    _searchFocusNode.unfocus();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {});
  }

  void searchContacts(String search) {
    setState(() {
      _stream = CRUDservice().getContacts(searchQuery: search);
    });
  }

  @override
  void initState() {
    _stream = CRUDservice().getContacts();
    _searchController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _unfocusTextField,
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              onPressed: signUserOut,
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
            ),
          ],
          title: const Text(
            'Desafio 3 - digiUP',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddContactPage()),
            );
          },
          backgroundColor: Colors.blue,
          child: const Icon(
            Icons.person_add,
            color: Colors.white,
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _searchController,
                onChanged: (value) {
                  searchContacts(value);
                },
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Pesquisa um contacto..',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    onPressed: _clearSearch,
                    icon: Icon(Icons.close),
                  )
                      : null,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _stream,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Algo de errado não está certo',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhum contacto encontrado.',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    );
                  }

                  return ListView(
                    children: snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                      return ListTile(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateContact(docID: document.id),
                          ),
                        ),
                        leading: CircleAvatar(
                          child: Text(data['name'][0]),
                        ),
                        title: Text(data['name']),
                        subtitle: Text(data['phone']),
                        trailing: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.call),
                        ),
                      );
                    }).toList().cast(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

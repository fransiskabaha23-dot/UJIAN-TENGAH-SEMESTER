import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Product layout demo home page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Listing')),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(2.0, 10.0, 2.0, 10.0),
        children: const <Widget>[
          StudentInfo(
            students: [
              Student(name: 'Fransiska Baha', nim: '235410077'),
              Student(name: 'Johanes B.S. Rahmat', nim: '205410073'),
            ],
          ),
          ProductBox(
            name: 'iPhone',
            description: 'iPhone is the stylish phone ever',
            price: 1000,
            image: 'iphone.png',
          ),
          ProductBox(
            name: 'Pixel',
            description: 'Pixel is the most featureful phone ever',
            price: 800,
            image: 'pixel.png',
          ),
          ProductBox(
            name: 'Laptop',
            description: 'Laptop is most productive development tool',
            price: 2000,
            image: 'laptop.png',
          ),
          ProductBox(
            name: 'Tablet',
            description: 'Tablet is the most useful device ever for meeting',
            price: 1500,
            image: 'tablet.png',
          ),
          ProductBox(
            name: 'Pendrive',
            description: 'Pendrive is useful storage medium',
            price: 100,
            image: 'pendrive.png',
          ),
          ProductBox(
            name: 'Floppy Drive',
            description: 'Floppy drive is useful rescue storage medium',
            price: 20,
            image: 'floppy.png',
          ),
        ],
      ),
    );
  }
}

class Student {
  const Student({required this.name, required this.nim});

  final String name;
  final String nim;
}

class StudentInfo extends StatelessWidget {
  const StudentInfo({super.key, required this.students});

  final List<Student> students;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Disusun oleh:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            for (final s in students) Text('${s.name} - ${s.nim}'),
          ],
        ),
      ),
    );
  }
}

class ProductBox extends StatelessWidget {
  const ProductBox({
    super.key,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
  });

  final String name;
  final String description;
  final int price;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      height: 120,
      child: Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Image.asset(
              'assets/appimages/$image',
              width: 80,
              fit: BoxFit.contain,
              // Kalau gambar belum ada, tampilkan ikon sebagai pengganti
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image, size: 60),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(description),
                    Text('Price: $price'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
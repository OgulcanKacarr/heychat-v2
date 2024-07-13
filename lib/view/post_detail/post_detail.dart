import 'package:flutter/material.dart';

class PostDetail extends StatelessWidget {
  final String imageUrl; // Gönderi fotoğrafı
  final void Function()? onClose; // Kapatma fonksiyonu

  const PostDetail({
    required this.imageUrl,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose, // Arka plana tıklanınca kapatma işlemi
      child: Material(
        color: Colors.transparent, // Arka plan rengi (transparan siyah)
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Gönderi detayına tıklanınca kapanmaması için boş onTap
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(imageUrl),
                  SizedBox(height: 16),
                  // Gönderi detayları buraya eklenebilir
                  Text(
                    'Gönderi detayları buraya',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: onClose,
                    child: Text('Kapat'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

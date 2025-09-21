import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_recipe_generator/default.dart';
import 'constant/wording.dart';

class RecipePage extends StatelessWidget {
  final String recipe;

  const RecipePage({super.key, this.recipe = "..."});

  @override
  Widget build(BuildContext context) {
    void navigateBack() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DefaultApp()),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        navigateBack();
        return false; // prevent default back
      },
      child: Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
            onPressed: navigateBack,
          ),
          title: const Text(
            Wording.generateResult,
            style: TextStyle(color: Colors.white70, fontSize: 20),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      Wording.detailRecipe,
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    MarkdownBody(
                        data: recipe,
                        styleSheet: MarkdownStyleSheet(
                          p: const TextStyle(
                              color: Colors.white70, fontSize: 16, height: 1.5),
                          strong: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                    SizedBox(
                      height: 100,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

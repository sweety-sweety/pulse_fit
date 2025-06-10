import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../svg/models.dart';
import '../../svg/svg_painter.dart';
import '../../svg/utils.dart';

class MuscleSelectionPage extends StatefulWidget {
  final bool resetOnStart;
  final List<int> initialSelection;

  const MuscleSelectionPage({
    Key? key,
    this.resetOnStart = false,
    this.initialSelection = const [],
  }) : super(key: key);

  @override
  _MuscleSelectionPageState createState() => _MuscleSelectionPageState();
}

class _MuscleSelectionPageState extends State<MuscleSelectionPage> {
  static const assetPath = 'assets/muscles.svg';
  List<PathSvgItem>? _items;
  Size? _size;
  List<int> selectedIndexes = [];

  @override
  void initState() {
    super.initState();
    _loadSelection();
  }

  Future<void> _loadSelection() async {
    final prefs = await SharedPreferences.getInstance();

    final savedIndexes = widget.resetOnStart
        ? <int>[]
        : widget.initialSelection.isNotEmpty
        ? widget.initialSelection
        : prefs.getStringList('selectedMuscles')?.map((e) => int.parse(e)).toList() ?? [];

    final vectorImage = await getVectorImage(context, assetPath);

    final items = vectorImage.items.asMap().map((i, item) {
      final isSelected = savedIndexes.contains(i);
      return MapEntry(
        i,
        item.copyWith(
          originalFill: item.fill,
          fill: isSelected && item.fill != Colors.white ? Colors.orange : item.fill,
        ),
      );
    }).values.toList();

    setState(() {
      _items = items;
      selectedIndexes = savedIndexes;
      _size = vectorImage.size;
    });
  }

  void _toggleColor(int index) {
    final item = _items![index];
    if (item.fill != Colors.white) {
      setState(() {
        if (selectedIndexes.contains(index)) {
          selectedIndexes.remove(index);
          _items![index] = item.copyWith(
            fill: item.originalFill,
          ); // Сброс цвета
        } else {
          selectedIndexes.add(index);
          _items![index] = item.copyWith(fill: Colors.orange); // Выбор мышц
        }
      });
    }
  }

  Future<void> _saveSelection() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
      'selectedMuscles',
      selectedIndexes.map((e) => e.toString()).toList(),
    );
  }

  void _resetSelection() {
    setState(() {
      selectedIndexes.clear();
      _items =
          _items!
              .map((item) => item.copyWith(fill: item.originalFill))
              .toList();
    });
  }

  void _finishSelection() {
    _saveSelection();
    Navigator.pop(context, selectedIndexes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Выбор мышц")),
      body:
          _items == null || _size == null
              ? const Center(child: CircularProgressIndicator())
              : InteractiveViewer(
                child: Center(
                  child: FittedBox(
                    child: SizedBox(
                      width: _size!.width,
                      height: _size!.height,
                      child: Stack(
                        children: [
                          for (int index = 0; index < _items!.length; index++)
                            SvgPainterImage(
                              item: _items![index],
                              size: _size!,
                              onTap: () => _toggleColor(index),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: _resetSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Сбросить'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _finishSelection,
                child: const Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

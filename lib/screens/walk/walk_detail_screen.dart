import 'package:flutter/material.dart';
import 'package:petdays/components/custom_dialog.dart';
import 'package:petdays/components/info_column.dart';
import 'package:petdays/models/walk_model.dart';
import 'package:petdays/palette.dart';
import 'package:petdays/providers/walk/walk_state.dart';
import 'package:provider/provider.dart';

class WalkDetailScreen extends StatefulWidget {
  final int index;

  const WalkDetailScreen({
    super.key,
    required this.index,
  });

  @override
  State<WalkDetailScreen> createState() => _WalkDetailScreenState();
}

class _WalkDetailScreenState extends State<WalkDetailScreen> {
  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} ${_getDayOfWeek(date.weekday)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }

  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return '월요일';
      case 2:
        return '화요일';
      case 3:
        return '수요일';
      case 4:
        return '목요일';
      case 5:
        return '금요일';
      case 6:
        return '토요일';
      case 7:
        return '일요일';
      default:
        return '';
    }
  }

  void _deleteWalk() async {
    try {
      // await _walkProvider.deleteWalk(context.read<WalkState>().walkList[widget.index].walkId);
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('산책 기록 삭제 실패: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    WalkModel walkModel = context.read<WalkState>().walkList[widget.index];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.background,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomDialog(
                      title: '산책 기록 삭제',
                      message: '산책 기록을 삭제하면 복구할 수 없습니다.\n삭제하시겠습니까?',
                      onConfirm: _deleteWalk,
                    );
                  },
                );
              },
              child: Icon(Icons.delete, color: Palette.black),
            ),
          ),
        ],
      ),
      backgroundColor: Palette.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            InfoColumn(
              title: '함께한 반려동물',
              content: walkModel.pets.map((pet) => pet.name).join(', '),
            ),
            SizedBox(
              height: 20,
            ),
            InfoColumn(
              title: '날짜',
              content: _formatDate(walkModel.createAt.toDate()),
            ),
            SizedBox(
              height: 20,
            ),
            InfoColumn(
              title: '시간',
              content: _formatDuration(walkModel.duration),
            ),
            SizedBox(
              height: 20,
            ),
            InfoColumn(
              title: '거리',
              content:
                  '${(double.parse(walkModel.distance) / 1000).toStringAsFixed(2)}KM',
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              decoration: BoxDecoration(
                color: Palette.lightGray,
                borderRadius: BorderRadius.circular(8),
              ),
              height: 200,
              child: Image.network(
                walkModel.mapImageUrl,
                fit: BoxFit.cover,
              ),
            )
          ],
        ),
      ),
    );
  }

  String _formatDuration(String duration) {
    final parts = duration.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    final seconds = int.parse(parts[2]);
    return '${hours}시간 ${minutes}분 ${seconds}초';
  }
}

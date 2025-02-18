import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petdays/screens/walk/walk_map_screen.dart';
import 'package:provider/provider.dart';

import '../components/show_custom_dialog.dart';
import '../components/pd_circle_avatar.dart';
import '../components/w_bottom_confirm_button.dart';
import '../components/show_error_dialog.dart';
import '../exceptions/custom_exception.dart';
import '../models/pet_model.dart';
import '../palette.dart';
import '../providers/pet/pet_provider.dart';
import '../providers/pet/pet_state.dart';
import '../utils/permission_utils.dart';
import 'medical/medical_upload_screen.dart';

class SelectPetScreen extends StatefulWidget {
  final bool isMedical;

  const SelectPetScreen({
    super.key,
    required this.isMedical,
  });

  @override
  State<SelectPetScreen> createState() => _SelectPetScreenState();
}

class _SelectPetScreenState extends State<SelectPetScreen>
    with AutomaticKeepAliveClientMixin<SelectPetScreen> {
  late final PetProvider petProvider;
  List<int> selectedIndices = [];
  bool _isActive = false;

  @override
  bool get wantKeepAlive => true;

  void _checkBottomActive() {
    setState(() {
      _isActive = selectedIndices.isNotEmpty;
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      if (widget.isMedical) {
        selectedIndices = [index];
      } else {
        if (selectedIndices.contains(index)) {
          selectedIndices.remove(index);
        } else {
          selectedIndices.add(index);
        }
      }
      _checkBottomActive();
    });
  }

  void _getData() {
    String uid = context.read<User>().uid;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await petProvider.getPetList(uid: uid);
      } on CustomException catch (e) {
        showErrorDialog(context, e);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    petProvider = context.read<PetProvider>();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    PetState petState = context.watch<PetState>();
    List<PetModel> petList = petState.petList;

    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        backgroundColor: Palette.background,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  widget.isMedical ? '누구와 병원에 갔나요?' : '누구와 산책하나요?',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                    color: Palette.black,
                    letterSpacing: -0.6,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  widget.isMedical ? '중복 선택이 불가능합니다.' : '중복 선택이 가능합니다.',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Palette.mediumGray,
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          Expanded(
            child: Scrollbar(
              child: GridView.builder(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 30),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: 150,
                ),
                itemCount: petList.length,
                itemBuilder: (BuildContext context, int index) {
                  bool isSelected = selectedIndices.contains(index);
                  return GestureDetector(
                    onTap: () => _toggleSelection(index),
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        color: Palette.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Palette.black : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Palette.black.withOpacity(0.05),
                            offset: Offset(8, 8),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          PDCircleAvatar(
                            imageUrl: petList[index].image,
                            size: 100,
                          ),
                          SizedBox(height: 2),
                          Text(
                            petList[index].name,
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Palette.black,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomConfirmButtonWidget(
        isActive: _isActive,
        onConfirm: () async {
          if (widget.isMedical) {
            PetModel selectedPet = petList[selectedIndices[0]];
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MedicalUploadScreen(selectedPet: selectedPet),
              ),
            );
          } else {
            List<PetModel> selectedPets = selectedIndices.map((index) => petList[index]).toList();

            if (Platform.isAndroid) {
              showCustomDialog(
                context: context,
                hasCancelButton: false,
                title: '백그라운드 위치',
                message: '이 앱은 사용 중이 아닐 때도 위치 데이터를 수집하여 산책 경로를 추적합니다.',
                onConfirm: () async {
                  Navigator.pop(context);
                  // 권한 체크 후 화면 이동
                  final hasPermission = await PermissionUtils.checkLocationPermission(context);
                  if (!hasPermission) return;

                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WalkMapScreen(selectedPets: selectedPets),
                      ),
                    );
                  }
                },
              );
            } else {
              final hasPermission = await PermissionUtils.checkLocationPermission(context);
              if (!hasPermission) return;

              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WalkMapScreen(selectedPets: selectedPets),
                  ),
                );
              }
            }
          }
        },
        buttonText: widget.isMedical ? "다음" : "시작하기",
      ),
    );
  }
}

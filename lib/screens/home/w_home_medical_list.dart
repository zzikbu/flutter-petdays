import 'package:flutter/material.dart';
import 'package:petdays/models/medical_model.dart';

import '../../components/pd_ circle_avatar.dart';
import '../../palette.dart';
import '../medical/s_medical_detail.dart';
import '../medical/s_medical_home.dart';
import '../../components/pd_title_with_more_button.dart';

class HomeMedicalListWidget extends StatelessWidget {
  final List<MedicalModel> medicalList;

  const HomeMedicalListWidget({
    super.key,
    required this.medicalList,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PDTitleWithMoreButton(
          title: '진료기록',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MedicalHomeScreen()),
            );
          },
        ),
        SizedBox(height: 10),
        medicalList.isEmpty
            ? Container(
                margin: EdgeInsets.only(bottom: 12),
                height: 70,
                decoration: BoxDecoration(
                  color: Palette.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Palette.black.withOpacity(0.05),
                      offset: Offset(8, 8),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "진료기록이 없습니다",
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Palette.mediumGray,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
              )
            : SingleChildScrollView(
                primary: false,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    medicalList.length > 7 ? 7 : medicalList.length, // 최대 7개
                    (index) {
                      MedicalModel medicalModel = medicalList[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MedicalDetailScreen(index: index)),
                          );
                        },

                        // 흰색 카드 영역
                        child: Container(
                          margin: EdgeInsets.only(right: 12, bottom: 10),
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            color: Palette.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Palette.black.withOpacity(0.05),
                                offset: Offset(8, 8),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    // 사진
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: PDCircleAvatar(
                                        imageUrl: medicalModel.pet.image,
                                        width: 36,
                                        height: 36,
                                      ),
                                    ),

                                    // 이름
                                    Expanded(
                                      child: Text(
                                        medicalModel.pet.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          color: Palette.black,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),

                                // 방문 날짜
                                Text(
                                  medicalModel.visitedDate,
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Palette.mediumGray,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                SizedBox(height: 6),

                                // 이유
                                Text(
                                  medicalModel.reason,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Palette.black,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
      ],
    );
  }
}

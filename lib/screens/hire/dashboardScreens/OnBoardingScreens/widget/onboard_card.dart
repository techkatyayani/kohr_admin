import 'package:Kohr_Admin/constants.dart';
import 'package:Kohr_Admin/screens/hire/dashboardScreens/OnBoardingScreens/model/candidate_model.dart';
import 'package:Kohr_Admin/screens/hire/dashboardScreens/OnBoardingScreens/widget/onboard_show_dialog.dart';
import 'package:flutter/material.dart';

class OnboardCard extends StatelessWidget {
  final CandidateModel candidateModel;
  const OnboardCard({
    super.key,
    required this.candidateModel,
  });

  @override
  Widget build(BuildContext context) {
// Helper method to format datetime
    String _formatDateTime(String dateString) {
      final dateTime =
          DateTime.parse(dateString); // Parse the string into DateTime
      return ' ${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    return InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return OnboardShowDialog(candidateModel: candidateModel);
            },
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Applied:',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      _formatDateTime(candidateModel.submittedAt.toString()),
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${candidateModel.firstName} ${candidateModel.lastName}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                '',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          candidateModel.profile,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      candidateModel.address,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      '${candidateModel.assessmentMarks} / 100',
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}

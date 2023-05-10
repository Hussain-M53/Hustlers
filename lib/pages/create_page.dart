import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:synew_gym/blocs/profile/profile_cubit.dart';
import 'package:synew_gym/constants/colors.dart';
import 'package:synew_gym/models/workout.dart';
import 'package:synew_gym/pages/create_new_workout.dart';
import 'package:synew_gym/pages/workout_page.dart';
import 'package:synew_gym/widgets/login_button.dart';

class CreatePage extends StatefulWidget {
  static const String routeName = '/createpage';

  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final TextEditingController _textEditingController = TextEditingController();

  late Workout? initialWorkout;

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _goToWorkoutPage(String workoutName) {
    int index = -1;
    Workout initialWorkout =
        context.read<ProfileCubit>().state.user.workouts!.firstWhere(
      (workout) {
        index++;
        return workout.name == workoutName;
      },
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutPage(
          workout: initialWorkout,
          workoutIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state.status == ProfileStatus.loaded) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
              body: Column(
                children: [
                  Expanded(
                    flex: 9,
                    child: ListView.builder(
                      itemCount: state.user.workouts!.length,
                      itemBuilder: (context, index) {
                        return Slidable(
                          key: Key(state.user.workouts![index].name),
                          startActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  context
                                      .read<ProfileCubit>()
                                      .selectWorkoutAsMain(
                                        state.user.workouts![index],
                                      );
                                },
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                icon: FontAwesomeIcons.heartCircleCheck,
                                label: 'Select',
                              ),
                            ],
                          ),
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  context.read<ProfileCubit>().deleteWorkout(
                                        state.user.workouts![index],
                                      );
                                },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Delete',
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(
                              state.user.workouts![index].name,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            subtitle: Text(
                              '@${state.user.username}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(fontSize: 10),
                            ),
                            leading: Icon(
                              Icons.fitness_center,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.arrow_forward_ios,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              onPressed: () => _goToWorkoutPage(
                                state.user.workouts![index].name,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            MyButton(
                              buttonText: 'Add Workout',
                              buttonColor: primaryColor,
                              buttonWidth: 300,
                              buttonHeight: 50,
                              buttonAction: () => Navigator.pushNamed(
                                context,
                                CreateNewWorkout.routeName,
                              ),
                              isSubmitting: false,
                              isOutlined: false,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:release_generator/title_provider.dart';
import 'package:release_generator/widgets/favorites_list.dart';


enum StateTransition {random, nextAnimal, nextAdjective, previousAnimal, previousAdjective}
class ReleaseNamGeneratorState{
  String adjective = '';
  String animal = '';
  String get fullName => '$adjective $animal'; 
  StateTransition transition = StateTransition.random;

  ReleaseNamGeneratorState(this.adjective, this.animal, this.transition);
}

// TODO: replace with Bloc
class ReleaseGeneratorCubit extends Cubit<ReleaseNamGeneratorState?> {
  late ReleaseNameGenerator gen;
  late ReleaseNameModelIndex idx;
  ReleaseNameWordsModel? model;

  ReleaseGeneratorCubit() : super(null) {
    gen = ReleaseNameGenerator();
    idx = ReleaseNameModelIndex();

    ReleaseNameWordsModel.create().then((value) {
      model = value;

      gen.model = model;
      idx.model = model;
      randomReleaseName();
    });
  }

  void randomReleaseName() {
    if (model == null) {
      emit(null);
    }

    idx = gen.randomIndex();
    _emitState();
  }

  void nextAdjective(){
    idx.nextAdjective();
    _emitState(StateTransition.nextAdjective);
  }
  void nextAnimal(){
    idx.nextAnimal();
    _emitState(StateTransition.nextAnimal);
  }
  void previousAdjective(){
    idx.previousAdjective();
    _emitState(StateTransition.previousAdjective);
  }
  void previousAnimal(){
    idx.previousAnimal();
    _emitState(StateTransition.previousAnimal);
  }


  void _emitState([transition = StateTransition.random]){
    emit(ReleaseNamGeneratorState(model!.adjectiveAt(idx)!, model!.animalAt(idx)!, transition));
  }
}


class Page1 extends StatelessWidget {
  Page1({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReleaseGeneratorCubit>(
        create: (context) => ReleaseGeneratorCubit(),
        child: Center(
          child: BlocBuilder<ReleaseGeneratorCubit, ReleaseNamGeneratorState?>(
            builder: (context, state) {
              final isLoaded = context.read<ReleaseGeneratorCubit>().state != null;

              return isLoaded 
                ? generatorBuilder(context, state!)
                : const Center(
                  child: CircularProgressIndicator(),
                );
            },
          ),
        ),
    );
  }
}

SwitchStyle switchStyleFromStateTransition(StateTransition stateTransition){
  switch (stateTransition) {
    case StateTransition.nextAdjective:
    case StateTransition.nextAnimal:
      return SwitchStyle.next;
    case StateTransition.previousAdjective:
    case StateTransition.previousAnimal:
      return SwitchStyle.previous;
    default:
      return SwitchStyle.fade;
  }
}


enum SwitchStyle{fade, next, previous}

Widget textSwitcherBuilder(BuildContext context, String text, [SwitchStyle style = SwitchStyle.fade]){
  return AnimatedSwitcher(
    duration: const Duration(milliseconds: 500),
    reverseDuration: const Duration(milliseconds: 500),
    transitionBuilder: (Widget child, Animation<double> animation){ 
      if(style == SwitchStyle.fade){
        return FadeTransition(opacity: animation, child: child);
      }

      var startOffset = const Offset(1.0, 0);

      if((style == SwitchStyle.next && child.key != ValueKey<String>(text))
      || (style == SwitchStyle.previous && child.key == ValueKey<String>(text))){
        startOffset = startOffset.scale(-1, -1);
      }

       var offset = Tween<Offset>(
         begin: startOffset,
         end: const Offset(0.0, 0.0),
       ).animate(animation);

      return FadeTransition(
        opacity: animation, 
        child: 
          SlideTransition(
            position: offset,
            child: child
          )
      );
    },

    child: Text(key: ValueKey<String>(text), text, textAlign: TextAlign.center),
  );  
}

Widget generatorBuilder(BuildContext context, ReleaseNamGeneratorState state){
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded( child: 
              TextButton(
                onPressed: ()=> context.read<ReleaseGeneratorCubit>().previousAdjective(), 
                child: const Icon(Icons.navigate_before),
              )
            ),
            Expanded(child: 
              textSwitcherBuilder(context, state.adjective, switchStyleFromStateTransition(state.transition)),
            ),
            Expanded(child: 
              TextButton(
                onPressed: ()=> context.read<ReleaseGeneratorCubit>().nextAdjective(), 
                child: const Icon(Icons.navigate_next)
              )
            )
          ],
        ),
        Row(
          children: [
            Expanded(child:
              TextButton(
                onPressed: ()=> context.read<ReleaseGeneratorCubit>().previousAnimal(), 
                child: const Icon(Icons.navigate_before),
              )
            ),
            Expanded(child: 
              textSwitcherBuilder(context, state!.animal, switchStyleFromStateTransition(state.transition)),
            ),
            Expanded(child: 
              TextButton(
                onPressed: ()=> context.read<ReleaseGeneratorCubit>().nextAnimal(), 
                child: const Icon(Icons.navigate_next)
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Icon(Icons.copy),
              onPressed: () => Clipboard.setData(ClipboardData(text: state.fullName)),
            ),
            ElevatedButton(
              child: const Text('Random'),
              onPressed: () => context.read<ReleaseGeneratorCubit>().randomReleaseName(),
            ),
            BlocBuilder<FavoriteNames, List<String>>(
              builder: (context, favoritesState){
                final isBookmarked = favoritesState.contains(state.fullName);
                return ElevatedButton(
                  child: isBookmarked
                    ? const Icon(Icons.star)
                    : const Icon(Icons.star_border),
                   onPressed: (){
                     isBookmarked
                      ? context.read<FavoriteNames>().remove(state.fullName)
                      : context.read<FavoriteNames>().add(state.fullName);
                   } 
                  );
                },
            )
          ],
        ),
    ],
  );
}
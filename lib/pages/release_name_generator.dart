import 'package:flutter/gestures.dart';
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

abstract class GeneratorEvent{}
class NextAdjective extends GeneratorEvent{}
class PrevAdjective extends GeneratorEvent{}
class NextAnimal extends GeneratorEvent{}
class PrevAnimal extends GeneratorEvent{}
class RandomTitle extends GeneratorEvent{}

class ReleaseGeneratorBloc extends Bloc<GeneratorEvent, ReleaseNamGeneratorState?> {
  late ReleaseNameGenerator gen;
  late ReleaseNameModelIndex idx;
  ReleaseNameWordsModel? model;

  ReleaseGeneratorBloc() : super(null) {
    gen = ReleaseNameGenerator();
    idx = ReleaseNameModelIndex();

    on<NextAdjective>(_nextAdjective);
    on<PrevAdjective>(_previousAdjective);
    on<NextAnimal>(_nextAnimal);
    on<PrevAnimal>(_previousAnimal);
    on<RandomTitle>(_randomReleaseName);

    ReleaseNameWordsModel.create().then((value) {
      model = value;
      gen.model = model;
      idx.model = model;
      add(RandomTitle());
    });
  }

   @override
  void onChange(Change<ReleaseNamGeneratorState?> change) {
    super.onChange(change);
  }

  void _randomReleaseName(GeneratorEvent event, Emitter<ReleaseNamGeneratorState?> emit) {
    if (model == null) {
      emit(null);
    }

    idx = gen.randomIndex();
    _emitStateHelper(emit, StateTransition.random);
  }

  void _nextAdjective(GeneratorEvent event, Emitter<ReleaseNamGeneratorState?> emit){
    idx.nextAdjective();
    _emitStateHelper(emit, StateTransition.nextAdjective);
  }
  void _nextAnimal(GeneratorEvent event, Emitter<ReleaseNamGeneratorState?> emit){
    idx.nextAnimal();
    _emitStateHelper(emit, StateTransition.nextAnimal);
  }
  void _previousAdjective(GeneratorEvent event, Emitter<ReleaseNamGeneratorState?> emit){
    idx.previousAdjective();
    _emitStateHelper(emit, StateTransition.previousAdjective);
  }
  void _previousAnimal(GeneratorEvent event, Emitter<ReleaseNamGeneratorState?> emit){
    idx.previousAnimal();
    _emitStateHelper(emit, StateTransition.previousAnimal);
  }

  void _emitStateHelper(Emitter<ReleaseNamGeneratorState?> emit, [transition = StateTransition.random]){
    emit(ReleaseNamGeneratorState(model!.adjectiveAt(idx)!, model!.animalAt(idx)!, transition));
  }
}


class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReleaseGeneratorBloc>(
        create: (context) => ReleaseGeneratorBloc(),
        child: Center(
          child: BlocBuilder<ReleaseGeneratorBloc, ReleaseNamGeneratorState?>(
            builder: (context, state) {
              final isLoaded = context.read<ReleaseGeneratorBloc>().state != null;

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
    duration: const Duration(milliseconds: 250),
    reverseDuration: const Duration(milliseconds: 250),
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
  final generatorBloc = BlocProvider.of<ReleaseGeneratorBloc>(context);
  final animals = generatorBloc.model!.animalsForLetter(generatorBloc.idx.letter);
  final adjectives = generatorBloc.model!.adjectivesForLetter(generatorBloc.idx.letter);

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 25,
          width: 200,
          child: Center(child: 
            StatelessWordCarusel(
              words: animals!,
              currentIndex: generatorBloc.idx.animalIndex,
              onNextPage: ()=> generatorBloc.add(NextAnimal()),
              onPrevPage: ()=> generatorBloc.add(PrevAnimal())
            )),
        ),

        Row(
          children: [
            Expanded( child: 
              TextButton(
                onPressed: ()=> context.read<ReleaseGeneratorBloc>().add(PrevAdjective()), 
                child: const Icon(Icons.navigate_before),
              )
            ),
            Expanded(child: 
              textSwitcherBuilder(context, state.adjective, switchStyleFromStateTransition(state.transition)),
            ),
            Expanded(child: 
              TextButton(
                onPressed: ()=> context.read<ReleaseGeneratorBloc>().add(NextAdjective()), 
                child: const Icon(Icons.navigate_next)
              )
            )
          ],
        ),
        Row(
          children: [
            Expanded(child:
              TextButton(
                onPressed: ()=> context.read<ReleaseGeneratorBloc>().add(PrevAnimal()), 
                child: const Icon(Icons.navigate_before),
              )
            ),
            Expanded(child: 
              textSwitcherBuilder(context, state.animal, switchStyleFromStateTransition(state.transition)),
            ),
            Expanded(child: 
              TextButton(
                onPressed: ()=> context.read<ReleaseGeneratorBloc>().add(NextAnimal()), 
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
              onPressed: () => context.read<ReleaseGeneratorBloc>().add(RandomTitle()),
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



class StatefulWordCarousel extends StatefulWidget{
  const StatefulWordCarousel({
    Key? key,
    required this.words,
    required this.onNextPage,
    required this.onPrevPage,
    required this.currentIndex
  }) : super(key: key);

  final List<String> words;
  final void Function() onNextPage;
  final void Function() onPrevPage;
  final int currentIndex;
  
  @override
  State<StatefulWordCarousel> createState() => _StatefulWordCarouselState();
}

class _StatefulWordCarouselState extends State<StatefulWordCarousel> {
  _StatefulWordCarouselState();

  final _pageController = PageController(
    viewportFraction: .5,
  );

  List<String> _words = [];
  set words(List<String> w){
    _words = w;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override 
  Widget build(BuildContext context){
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if(details.primaryVelocity! > 0){
          onPrevPage();
        }
        if(details.primaryVelocity! < 0){
          onNextPage();
        }
      },
      child: PageView.builder(
        scrollDirection: Axis.horizontal,
        controller: PageController(
          initialPage: currentIndex,
          viewportFraction: .5,
          ),
        itemCount: words.length * 3,
        itemBuilder: (BuildContext context, int index){

          return Container(
             color: index % 2 == 0 ? Colors.green : Colors.blue[700],
             child: Center(child: Text(words![index%words.length])));
        },
      ),
    );
  }
}

class StatelessWordCarusel extends StatelessWidget{
  StatelessWordCarusel({
    Key? key,
    required this.words,
    required this.onNextPage,
    required this.onPrevPage,
    required this.currentIndex
  }) : super(key: key);

  final List<String> words;
  final void Function() onNextPage;
  final void Function() onPrevPage;
  final int currentIndex;

  @override 
  Widget build(BuildContext context){
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if(details.primaryVelocity! > 0){
          onPrevPage();
        }
        if(details.primaryVelocity! < 0){
          onNextPage();
        }
      },
      child: PageView.builder(
        scrollDirection: Axis.horizontal,
        controller: PageController(
          initialPage: currentIndex,
          viewportFraction: .5,
          ),
        itemCount: words.length * 3,
        itemBuilder: (BuildContext context, int index){

          return Container(
             color: index % 2 == 0 ? Colors.green : Colors.blue[700],
             child: Center(child: Text(words![index%words.length])));
        },
      ),
    );
  }
}
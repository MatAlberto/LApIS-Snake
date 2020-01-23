Tabuleiro tab;
Snake snake;
Jogada currentPlay;
int moveDelay = 100;
int before=0;
int dir;
boolean pause=false;
NeuralNetwork network1;
NeuralNetwork[] networks;
AlgGenetico algGen;
int maxFramesWithoutEating;
int framesWithoutEating = 0;
int maxScore=0;
long seedFood = new Random().nextLong();
ArrayList<double[]> previousInputs;
KNN knn;
boolean humanPlay = false;
boolean saveAIGames = true;
boolean pauseWhenDie = false;
String respOriginal="",respRecu="";

void setup()
{
  size(600, 600);
  frameRate(500);
  initialize();
  network1 = new NeuralNetwork(new int[]{15, 30, 3}, new String[]{"LEFT", "RIGHT", "FRONT"});
  //networks = new NeuralNetwork[10];
  //for (int i=0; i<networks.length; i++)networks[i] = new NeuralNetwork(16, 30, 3, new String[]{"LEFT", "RIGHT", "FRONT"});
  if (!humanPlay)
  {
    File folder = new File(sketchPath("")+"/jogadas");
    println(folder.getAbsolutePath());
    ArrayList<InputOutput> l = new ArrayList<InputOutput>();
    for (File f : folder.listFiles())
    {
      Jogada j = new Jogada();
      j.loadData(f.getAbsolutePath());
      l.addAll(j.inOutNeuralNetwork());
    }
    int[] contEx= new int[3];
    for (InputOutput i : l)
    {
      if (i.ladoVirado.equals("LEFT"))contEx[0]++;
      else if (i.ladoVirado.equals("FRONT"))contEx[1]++;
      else contEx[2]++;
    }
    int min = Math.min(Math.min(contEx[0], contEx[1]), contEx[2]);
    println("MIN EXAMPLES: "+min);
      int[] cont = {contEx[0],contEx[1],contEx[2]};
      Collections.shuffle(l);
      ArrayList<InputOutput> a = new ArrayList<InputOutput>(l);
      for (int j=0; j<a.size(); j++)
      {
        int lado = -1;
        if (a.get(j).ladoVirado.equals("LEFT"))lado = 0;
        if (a.get(j).ladoVirado.equals("FRONT"))lado = 1;
        if (a.get(j).ladoVirado.equals("RIGHT"))lado = 2;
        if (cont[lado] >min)
        {
          cont[lado]--;
          a.remove(j--);
        }
      }
      network1.train(a);
      //knn = new KNN(1000,l.toArray(new InputOutput[0]));
   
    //algGen = new AlgGenetico(networks);
   // algGen = new AlgGenetico(10,10,30,3);
   // network1.inHdWeight = algGen.atual.inHdWeight;
    //network1.hdOutWeight = algGen.atual.hdOutWeight;
   
    //network1 = networks[0];
  }
}

void draw()
{
  background(0);
  if (millis()-before>moveDelay && !snake.isDead && pause)
  {
    before = millis();
    currentPlay.frameSave();
    if (humanPlay)snake.move(dir);
    else 
    {
      double[] inputs = new InputOutput(tab.rows, getInput(snake)).inputs;
      double aux = framesWithoutEating/(tab.rows*2-snake.score==0?1:tab.rows*2-snake.score);
      inputs[inputs.length-1] = 1/(1+Math.exp(-aux));
      
      if(loopDetection(inputs))
      {
        println("Reseted by loop detection");
        reset();
      }
      else
      {
        respOriginal = network1.evaluate(inputs);
        String[] options = {"LEFT","RIGHT","FRONT"};
        
        double[] optionsValues = evaluateRecursive(snake,6,inputs,options);
        int maxID = 0;
        for(int i=0;i<3;i++)if(optionsValues[i] > optionsValues[maxID])maxID = i;
        snake.moveRelative(options[maxID]);
        respRecu = options[maxID];
        if(optionsValues[0] + optionsValues[1] + optionsValues[2] == 0 && pauseWhenDie)noLoop();
        //if(!respOriginal.equals(options[maxID]))println("original:" + respOriginal + " combinado: " + options[maxID]);
      }
    }
    if (snake.isDead && (humanPlay || saveAIGames))currentPlay.saveData();
  }

 
  snake.snakeDraw();
  tab.tabDraw();
  textSize(15);
  text("Score: "+snake.score, 10, 15);
  text("Max Score: "+maxScore, 100, 15);
  text("Resp_or: "+respOriginal, 210, 15);
  text("Resp_re: "+respRecu, 410, 15);
  String tx="";
  //tx += "P(FRONT): "+(""+100*network1.outputActivation[2]).substring(0, min((""+network1.outputActivation[2]).length(), 5));
  //tx+= "\t P(LEFT): "+(""+100*network1.outputActivation[0]).substring(0, min((""+network1.outputActivation[0]).length(), 5));
  //tx+= "\t P(RIGHT): "+(""+100*network1.outputActivation[1]).substring(0, min((""+network1.outputActivation[1]).length(), 5));
  if (!humanPlay && algGen!= null)
  {
    tx+= "\t GEN: "+algGen.generationCount;
    tx+= "\t IND: "+ algGen.individuoCount;
    tx+= "\t MUT: "+ algGen.mutationCount;
    tx+= "\t REP: "+ algGen.reproductionCount;
    tx+= "\t CLO: "+ algGen.cloneCount;
  }
  //println(network.output[0] + " " +network.output[1] + " "+ network.output[2]);
  text(tx, 220, 15);
  if (snake.isDead)
  {
    //background(255, 0, 0);
    println("snake is dead");
    
    if (!humanPlay)
    {
      if(pauseWhenDie)noLoop();
      reset();
    }
  }
  //println(dir);
}

void reset()
{
  if(!humanPlay && algGen != null)resetAlgGen();
  initialize();
}

void initialize()
{
  tab = new Tabuleiro();
  maxFramesWithoutEating = 2*tab.rows;
  snake = new Snake(tab.rows/2, tab.rows/2, 3);
  dir=Snake.EAST;
  snake.dir = dir; 
  snake.score = 0;
  tab.newFood();
  currentPlay = new Jogada();
  previousInputs = new ArrayList<double[]>();
}

void resetAlgGen()
{
  algGen.atual.fitness = snake.score+1;
  algGen.setNextIndividuo();
  //network1.inHdWeight = algGen.atual.inHdWeight;
  //network1.hdOutWeight = algGen.atual.hdOutWeight;
}

void keyPressed()
{
  if (keyCode == UP && snake.dir != Snake.SOUTH)dir = Snake.NORTH;
  else if (keyCode == DOWN && snake.dir != Snake.NORTH)dir = Snake.SOUTH;
  else if (keyCode == LEFT && snake.dir != Snake.EAST)dir = Snake.WEST;
  else if (keyCode == RIGHT && snake.dir != Snake.WEST)dir = Snake.EAST;
  if (key == 'r') reset();
  if (key == 'p') pause = !pause;
  if (key == 'k') moveDelay = Math.max(1, moveDelay-5);
  if (key == 'l') moveDelay += 5;
  if (key == 'm') loop();
}

String getInput(Snake sna)
{
  String s = 0+";"+sna.dir+";"+tab.food.x+";"+tab.food.y;
  Node n = sna.tail;
  while (n != null)
  {
    s += ";"+n.x+";"+n.y+"";
    n = n.next;
  }
  return s;
}


boolean loopDetection(double[] inputs)
{
  for(double[] previous: previousInputs)
  {
    boolean equal = true;
    for(int i=0;i<previous.length;i++)
    {
      if(previous[i] != inputs[i])
      {
        equal = false;
        break;
      }
    }
    if(equal)return true;
  }
  previousInputs.add(inputs);
  return false;
}



double[] evaluateRecursive(Snake sn, int futureDecisionNumber, double[] inputs, String[] options)
{
  network1.evaluate(inputs);
  double[] optionsValues = {network1.output[0],network1.output[1],network1.output[2]};
  if(futureDecisionNumber>0)
  {
    for(int i=0;i<options.length;i++)
    {
       Snake clone = sn.cloneSnake();
       clone.isActive = false;
       clone.moveRelative(options[i]);
       if(clone.isDead)optionsValues[i]=0;
       else
       {
         double[] nextIteration = evaluateRecursive(clone,futureDecisionNumber-1,new InputOutput(tab.rows, getInput(clone)).inputs,options);
         optionsValues[i] *= Math.max(Math.max(nextIteration[0],nextIteration[1]),nextIteration[2]);
       }
     }
  }
   return optionsValues;
}

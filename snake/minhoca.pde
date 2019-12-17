Tabuleiro tab;
Snake snake;
Jogada currentPlay;
int moveDelay = 100;
int before=0;
int dir;
boolean pause=false;
NeuralNetwork[] networks;
int maxFramesWithoutEating;
int framesWithoutEating = 0;
int maxScore=0;

boolean humanPlay = true;

void setup()
{
  size(600,600);
  reset();
  networks = new NeuralNetwork[10];
  for(int i=0;i<networks.length;i++)networks[i] = new NeuralNetwork(10,10,3,new String[]{"LEFT","RIGHT","FRONT"});
  if(!humanPlay)
  {
    File folder = new File(sketchPath("")+"/jogadas");
    println(folder.getAbsolutePath());
    ArrayList<InputOutput> l = new ArrayList<InputOutput>();
    for(File f: folder.listFiles())
    {
      Jogada j = new Jogada();
      j.loadData(f.getAbsolutePath());
      l.addAll(j.inOutNeuralNetwork());
    }
    for(int i=0;i<networks.length;i++)networks[i].train(l);
  }
}

void draw()
{
  if(millis()-before>moveDelay && !snake.isDead && pause)
  {
    before = millis();
    currentPlay.frameSave();
    if(humanPlay)snake.move(dir);
    else 
    {
      double[] inputs = new InputOutput(tab.rows,getInput()).inputs;
      double r = (double) framesWithoutEating/maxFramesWithoutEating;
      if(r>0.3)
      {
        //println("RANDOM");
        framesWithoutEating = 0;
        for(int i=0;i<inputs.length;i++)if(random(1)<r) inputs[i] = random(1);
      }
      int[] contOptions = new int[3];
      for(NeuralNetwork network: networks)
      {
        String resp = network.evaluate(inputs);
        if(resp.equals("FRONT"))contOptions[0]++;
        else if(resp.equals("LEFT"))contOptions[1]++;
        else contOptions[2]++;
      }
      if(contOptions[0]>contOptions[1] && contOptions[0]>contOptions[2])snake.moveRelative("FRONT");
      else if(contOptions[1] > contOptions[2])snake.moveRelative("LEFT");
      else snake.moveRelative("RIGHT");
    }
    if(snake.isDead && humanPlay)currentPlay.saveData();
  }
  
  background(0);
  snake.snakeDraw();
  tab.tabDraw();
  textSize(15);
  text("Score: "+snake.score,10,15);
  text("Max Score: "+snake.score,100,15);
  //String tx = "P(FRONT): "+(""+100*network.outputActivation[2]).substring(0,min((""+network.outputActivation[2]).length(),5));
  //tx+= "\t P(LEFT): "+(""+100*network.outputActivation[0]).substring(0,min((""+network.outputActivation[0]).length(),5));
  //tx+= "\t P(RIGHT): "+(""+100*network.outputActivation[1]).substring(0,min((""+network.outputActivation[1]).length(),5));
 // println(network.output[0] + " " +network.output[1] + " "+ network.output[2]);
  //text(tx,220,15);
  if(snake.isDead)
  {
    background(255,0,0);
    if(!humanPlay)reset();
  }
  if(!humanPlay && framesWithoutEating > maxFramesWithoutEating)
  {
    framesWithoutEating = 0;
    reset();
  }
  //println(dir);
}

void reset()
{
  tab = new Tabuleiro();
  maxFramesWithoutEating = tab.rows*tab.cols+100;
  snake = new Snake(tab.rows/2,tab.rows/2,3);
  dir=Snake.EAST;
  snake.dir = dir;
  snake.score = 0;
  tab.newFood();
  currentPlay = new Jogada();
}

void keyPressed()
{
  if(keyCode == UP && snake.dir != Snake.SOUTH)dir = Snake.NORTH;
  else if(keyCode == DOWN && snake.dir != Snake.NORTH)dir = Snake.SOUTH;
  else if(keyCode == LEFT && snake.dir != Snake.EAST)dir = Snake.WEST;
  else if(keyCode == RIGHT && snake.dir != Snake.WEST)dir = Snake.EAST;
  if(key == 'r') reset();
  if(key == 'p') pause = !pause;
}

String getInput()
{
  String s = 0+";"+snake.dir+";"+tab.food.x+";"+tab.food.y;
  Node n = snake.tail;
  while(n != null)
  {
    s += ";"+n.x+";"+n.y+"";
    n = n.next;
  }
  return s;
  
}

class InputOutput
{
  double[] inputs;
  double[] outputs;
  int dir;
  String ladoVirado;
  
  InputOutput(int sizeTab, String frame)
  {
    String[] parts = frame.split(";");
    dir = int(parts[0]);
    int dirAtual = int(parts[1]);
    Node food = new Node(int(parts[2]),int(parts[3]));
    Node[] snake = new Node[(parts.length-4)/2];
    for(int i=4, j=0;j<snake.length;i+=2,j++)snake[j] = new Node(int(parts[i]),int(parts[i+1]));
    Node head = snake[snake.length-1];
    while(dirAtual>0)
    {
      for(Node n:snake)n.rotateLeft(sizeTab);
      food.rotateLeft(sizeTab);
      dir--;
      dirAtual--;
    }
    dir = ((dir+4)%4);
    //a cobra agora esta apontando para o norte
    
    double distFrente=1+head.y;
    double distEsq=1+head.x;
    double distDir=sizeTab-head.x;
    double distFood = sqrt(pow(head.x-food.x,2)+pow(head.y-food.y,2))/sizeTab;
    double foodInFront = head.y>food.y?1:0;
    double foodInLeft = head.x>food.x?1:0;
    double foodInRight = head.x<food.x?1:0;
    double gradFront = sqrt(pow(head.x-food.x,2)+pow(head.y-food.y-1,2))/sizeTab - distFood;
    double gradLeft = sqrt(pow(head.x-food.x+1,2)+pow(head.y-food.y,2))/sizeTab - distFood;
    double size = snake.length/sizeTab;
    
    for(int node=0;node<snake.length-1;node++)
    {
      if(head.x == snake[node].x && head.y> snake[node].y && head.y-snake[node].y<distFrente) distFrente = head.y-snake[node].y;
      if(head.y == snake[node].y)
      {
        if(head.x > snake[node].x && head.x-snake[node].x<distEsq)distEsq = head.x-snake[node].x;
        if(head.x < snake[node].x && snake[node].x-head.x<distDir)distDir = snake[node].x-head.x;
      }
    }
    distFrente /= sizeTab;
    distEsq /= sizeTab;
    distDir /= sizeTab;
    //if(foodInFront==0)distFrente = -distFrente;
    //if(foodInLeft==1)distEsq = -distDir;
    
    inputs = new double[]{distFrente,distEsq, distFood,foodInLeft, foodInRight,foodInFront,gradFront,gradLeft,size,0};
    outputs = new double[]{dir==Snake.WEST?1:0,dir==Snake.EAST?1:0,dir==Snake.NORTH?1:0};
    if(outputs[0]==1)ladoVirado = "LEFT";
    else if(outputs[1]==1)ladoVirado = "RIGHT";
    else ladoVirado = "FRONT";
  }
  
}

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
    double distEsqFrente = Math.min(distFrente,distEsq);
    double distDirFrente = Math.min(distFrente,distDir);
    double distFood = sqrt(pow(head.x-food.x,2)+pow(head.y-food.y,2))/sizeTab;
    double foodInFront = head.y>food.y?1:0;
    double foodInLeft = head.x>food.x?1:0;
    double foodInRight = head.x<food.x?1:0;
    double gradFront = sqrt(pow(head.x-food.x,2)+pow(head.y-food.y-1,2))/sizeTab - distFood;
    double gradLeft = sqrt(pow(head.x-food.x+1,2)+pow(head.y-food.y,2))/sizeTab - distFood;
    double size = snake.length/sizeTab;
    double areaFront,areaLeft,areaRight;
    
    boolean[][] visited= new boolean[sizeTab][sizeTab];
    for(int i=1;i<snake.length;i++)visited[snake[i].x][snake[i].y] = true;
    areaFront = getArea(head.x,head.y-1,visited.clone())/pow(sizeTab,2);
    areaLeft = getArea(head.x-1,head.y,visited.clone())/pow(sizeTab,2);
    areaRight = getArea(head.x+1,head.y,visited.clone())/pow(sizeTab,2);
    
    
    for(int node=0;node<snake.length-1;node++)
    {
      if(head.x == snake[node].x && head.y> snake[node].y && head.y-snake[node].y<distFrente) distFrente = head.y-snake[node].y;
      if(head.y == snake[node].y)
      {
        if(head.x > snake[node].x && head.x-snake[node].x<distEsq)distEsq = head.x-snake[node].x;
        if(head.x < snake[node].x && snake[node].x-head.x<distDir)distDir = snake[node].x-head.x;
      }
      if(head.x-snake[node].x>0 && head.x-snake[node].x == head.y-snake[node].y && head.x-snake[node].x<distEsqFrente)distEsqFrente = head.x-snake[node].x;
      if(head.y-snake[node].y>0 && -head.x+snake[node].x == head.y-snake[node].y && head.y-snake[node].y<distDirFrente)distDirFrente = head.y-snake[node].y;
    }
    distFrente /= sizeTab;
    distEsq /= sizeTab;
    distDir /= sizeTab;
    distDirFrente /= sizeTab;
    distEsqFrente /= sizeTab;
    //if(foodInFront==0)distFrente = -distFrente;
    //if(foodInLeft==1)distEsq = -distDir;
    
    
    
    inputs = new double[]{distFrente, distEsq, distDir, distEsqFrente, distDirFrente, distFood,foodInLeft, foodInRight,foodInFront,gradFront,gradLeft,
                          size,areaFront,areaLeft,areaRight};
                          
                          
                          
    outputs = new double[]{dir==Snake.WEST?1:0,dir==Snake.EAST?1:0,dir==Snake.NORTH?1:0};
    if(outputs[0]==1)ladoVirado = "LEFT";
    else if(outputs[1]==1)ladoVirado = "RIGHT";
    else ladoVirado = "FRONT";
  }
  
  
  double getArea(int x,int y,boolean[][] visited)
  {
    if(x<0 || x>=visited.length || y<0 || y>=visited[0].length)return 0;
    if(visited[x][y])return 0;
    double cont=1;
    visited[x][y] = true;
    cont += getArea(x-1,y,visited);
    cont += getArea(x+1,y,visited);
    cont += getArea(x,y-1,visited);
    cont += getArea(x,y+1,visited);
    return cont;
  }
  
}

class InputOutputFront extends InputOutput
{
  InputOutputFront(int sizeTab, String frame)
  {
    super(sizeTab, frame);
    if(!ladoVirado.equals("FRONT"))ladoVirado = "NOT";
  }
}

class InputOutputLeft extends InputOutput
{
  InputOutputLeft(int sizeTab, String frame)
  {
    super(sizeTab, frame);
    if(!ladoVirado.equals("LEFT"))ladoVirado = "NOT";
  }
}

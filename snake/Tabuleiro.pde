class Tabuleiro
{
  int initX=20,initY=20;
  int rows=20,cols=20;
  int sizeSquare=(width-2*initX)/rows;
  Random foodChooser = new Random();
  Node food;
  
  void tabDraw()
  {
    stroke(255);
    for(int i=0;i<rows+1;i++)
      line(initX,initY+i*sizeSquare,initX+sizeSquare*cols,initY+i*sizeSquare);
    for(int i=0;i<cols+1;i++)
      line(initX+i*sizeSquare,initY,initX+i*sizeSquare,initY+rows*sizeSquare);
    fill(255,255,0);
    rect(initX+food.x*sizeSquare,initY+food.y*sizeSquare,sizeSquare,sizeSquare);
  }
  
  void newFood()
  {
    while(true)
    {
      food = new Node(foodChooser.nextInt(rows),foodChooser.nextInt(cols));
      Node n = snake.tail;
      boolean done=true;
      while(n != null)
      {
        if(n.x == food.x && n.y == food.y)done = false;
        n = n.next;
      }
      if(done)break;
    }
    
    
    
  }
  
}

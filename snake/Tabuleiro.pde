class Tabuleiro
{
  int initX=20,initY=20;
  int rows=20,cols=20;
  int sizeSquare=(width-2*initX)/rows;
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
      food = new Node(int(random(rows)),int(random(cols)));
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

class Snake
{
  static final int NORTH=0, EAST=1, SOUTH=2,  WEST=3;
  Node head;
  Node tail;
  int dir;
  int score = 0;
  boolean isDead=false;
  
  Snake(int x, int y, int l)
  {
    head = new Node(x,y);
    Node aux = head;
    for(int i=1;i<l;i++)
    {
      Node n = new Node(x-i,y);
      n.next = aux;
      aux = n;
    }
    tail = aux;
    head.next = null;
  }
  
  void move(int dir)
  {
    Node n = tail;
    while(n != head)
    {
      n.x = n.next.x;
      n.y = n.next.y;
      n = n.next;
    }
    switch(dir)
    {
      case NORTH:
        head.y--;
      break;
      case SOUTH:
        head.y++;
      break;
      case EAST:
       head.x++;
      break;
      case WEST:
       head.x--;
    }
    this.dir = dir;
    deathCheck();
    eatCheck();
  }
  
  void moveRelative(String d)
  {
    //println(d);
    if(d.equals("LEFT"))move((this.dir+3)%4);
    else if(d.equals("RIGHT"))move((this.dir+1)%4);
    else move(this.dir);
  }
  
  void eatCheck()
  {
    if(head.x == tab.food.x && head.y == tab.food.y)
    {
      eat();
      tab.newFood();
      score++;
      if(this.score > maxScore)maxScore = score;
      framesWithoutEating = 0;
    }
    else framesWithoutEating++;
  }
  
  void deathCheck()
  {
    Node n= tail;
    while(n != head)
    {
      if(n.x == head.x && n.y==head.y)
      {
        isDead = true;
        return;
      }
      n = n.next;
    }
    if(head.x>=tab.cols || head.x < 0 || head.y >= tab.rows || head.y < 0)isDead=true;
    
  }
  
  
  void eat()
  {
    Node n = new Node(tail.x,tail.y);
    n.next = tail;
    tail = n;
  }
  
  void snakeDraw()
  {
    fill(0,255,0);
    Node n=tail;
    while(n != null)
    {
      rect(tab.initX+n.x*tab.sizeSquare,tab.initY+n.y*tab.sizeSquare,tab.sizeSquare,tab.sizeSquare);
      n= n.next;
    }
      
  }
  
  
}


class Node
{
  int x, y;
  Node next;
  Node (int a,int b)
  {
    x = a;
    y = b;
  }
  
  void rotateLeft(int sizeTab)
  {
    int yNew = sizeTab-1-x;
    x = y;
    y = yNew;
    
  }
  
}

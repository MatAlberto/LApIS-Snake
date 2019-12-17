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
      previousInputs.clear();
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

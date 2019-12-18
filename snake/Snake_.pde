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
    
    float eye1x = tab.initX+head.x*tab.sizeSquare;
    float eye1y = tab.initY+head.y*tab.sizeSquare;
    float eye2x = eye1x, eye2y = eye1y;
    float mouthx= eye1x, mouthy = eye1y,mouthw=0,mouthh=0;
    switch(dir)
    {
      case EAST:
      eye1x = eye2x = eye1x+tab.sizeSquare*0.6;
      eye1y += 0.2*tab.sizeSquare;
      eye2y += 0.6*tab.sizeSquare;
      mouthx += 0.85*tab.sizeSquare;
      mouthy += 0.15*tab.sizeSquare;
      mouthh = 0.7*tab.sizeSquare;
      mouthw = 0.15*tab.sizeSquare;
      break;
      case WEST:
      eye1x = eye2x = eye1x+tab.sizeSquare*0.2;
      eye1y += 0.2*tab.sizeSquare;
      eye2y += 0.6*tab.sizeSquare;
      mouthh = 0.7*tab.sizeSquare;
      mouthy += 0.15*tab.sizeSquare;
      mouthw = 0.15*tab.sizeSquare;
      break;
      case NORTH:
      eye1y = eye2y = eye1y+0.2*tab.sizeSquare;
      eye1x += 0.2*tab.sizeSquare;
      eye2x += 0.6*tab.sizeSquare;
      mouthw = 0.7*tab.sizeSquare;
      mouthx += 0.15*tab.sizeSquare;
      mouthh = 0.15*tab.sizeSquare;
      break;
      case SOUTH:
      eye1y = eye2y = eye1y+0.6*tab.sizeSquare;
      eye1x += 0.2*tab.sizeSquare;
      eye2x += 0.6*tab.sizeSquare;
      mouthy += 0.85*tab.sizeSquare;
      mouthw = 0.7*tab.sizeSquare;
      mouthx += 0.15*tab.sizeSquare;
      mouthh = 0.15*tab.sizeSquare;
      break;
    }
    fill(0,0,255);
    rect(eye1x,eye1y,0.2*tab.sizeSquare,0.2*tab.sizeSquare);
    rect(eye2x,eye2y,0.2*tab.sizeSquare,0.2*tab.sizeSquare);
    fill(255,0,0);
    rect(mouthx,mouthy,mouthw,mouthh);
  }
  
  
}

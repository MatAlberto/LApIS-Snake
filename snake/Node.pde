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

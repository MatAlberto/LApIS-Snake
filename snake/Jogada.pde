import java.text.*;
import java.util.*;

class Jogada
{
  ArrayList<String> frames = new ArrayList<String>(Arrays.asList(new String[]{tab.rows+""}));
  
  void frameSave()
  {
    String s = dir+";"+snake.dir+";"+tab.food.x+";"+tab.food.y+"";
    Node n = snake.tail;
    while(n != null)
    {
      s += ";"+n.x+";"+n.y+"";
      n = n.next;
    }
    frames.add(s);
  }
  
  
  void saveData()
  {
    String name = new SimpleDateFormat("dd-MM-yyyy-HH-mm-ss'.txt'").format(new Date());
    saveStrings("./jogadas/"+name,frames.toArray(new String[0]));
  }
  
  void loadData(String name)
  {
    frames.clear();
    for(String s:loadStrings(name))frames.add(s);
  }
  
  
  ArrayList<InputOutput> inOutNeuralNetwork()
  {
    ArrayList<InputOutput> resp = new ArrayList<InputOutput>();;
    int sizeTab = int(frames.get(0));
    for(int i=1;i<frames.size();i++)
    {
      resp.add(new InputOutput(sizeTab,frames.get(i)));
    }
    return resp;
  }
  
  
}

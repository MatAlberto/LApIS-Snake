class KNN
{
  int k=4;
  InputOutput[] exemplos;
  
  KNN(int ka, InputOutput[] ex)
  {
    k = ka;
    exemplos = ex;
  }
  
  String evaluate(double[] in)
  {
    SortedMap<Double, InputOutput> sm = new TreeMap<Double, InputOutput>();
    for(InputOutput ex: exemplos)sm.put(-similarityCosineKNN(in,ex.inputs),ex);
    HashMap<String,Integer> m = new HashMap<String,Integer>();
    m.put("LEFT",0);
    m.put("RIGHT",1);
    m.put("FRONT",2);
    Set<Double> keys = sm.keySet();
    int[] contOption = new int[3];
    int aux=0;
    for(Double ke: sm.keySet())
    {
      contOption[m.get(sm.get(ke).ladoVirado)]++;
      aux++;
      if(aux==k)break;
    }
    if(contOption[0]>contOption[1])
    {
      if(contOption[0]>contOption[2])return "LEFT";
      else return "FRONT";
    }
    if(contOption[1]>contOption[2])return "RIGHT";
    else return "LEFT";
    
  }
  
  double distanceKNN(double[] in1, double[] in2)
  {
    double dist=0;
    for(int i =0;i<in1.length;i++)dist += Math.pow(in1[i]-in2[i],2);
    return Math.sqrt(dist);
  }
  
  double similarityCosineKNN(double[] in1, double[] in2)
  {
    double sum1=0,sum2=0,sumProduct=0;
    for(int i =0;i<in1.length;i++)
    {
      sum1 += Math.pow(in1[i],2);
      sum2 += Math.pow(in2[i],2);
      sumProduct += in1[i]*in2[i];
    }
    return sumProduct/(Math.sqrt(sum1)*Math.sqrt(sum2));
  }
  
}

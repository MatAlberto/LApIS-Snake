class NeuralNetwork
{
  int sizeInput;
  int sizeHidden;
  int sizeOut;
  double[][] inHdWeight;
  double[][] hdOutWeight;
  String[] labelsOut;
  double[] input,hidden,output;
  double[] hiddenActivation,outputActivation;
  double learningRate = 0.1;
  int epochs = 150;
  double percentageValidation=0.5;
  double[] outputActivationPrevious;
  
  NeuralNetwork(int in, int hd, int out, String[] labels)
  {
    sizeInput = in;
    sizeHidden = hd;
    sizeOut = out;
    inHdWeight = new double[in][hd];
    hdOutWeight = new double[hd][out];
    labelsOut = labels;
    hidden = new double[hd];
    output = new double[out];
    hiddenActivation = new double[hd];
    outputActivation = new double[out];
    outputActivationPrevious = new double[out];
    for(int i=0;i<outputActivationPrevious.length;i++)outputActivationPrevious[i] = 0.5;
    setRandom();
  }
  
  void train(List<InputOutput> examples)
  {
    println(examples.size());
    HashMap<String,Integer> mapa = new HashMap<String,Integer>();
    mapa.put("LEFT",0);mapa.put("RIGHT",1);mapa.put("FRONT",2);
    
    Collections.shuffle(examples);
    ArrayList<InputOutput> training = new ArrayList<InputOutput>();
    ArrayList<InputOutput> validation = new ArrayList<InputOutput>();
    int i;
    for(i=0;(double)(i+1)/examples.size()<percentageValidation;i++)validation.add(examples.get(i));
    for(;i<examples.size();i++)training.add(examples.get(i));
    
    
    for(int epoch=0;epoch<epochs;epoch++)
    {
      int[][] tabConfusaoTraining = new int[3][3];
      int[][] tabConfusaoValidation = new int[3][3];
      for(InputOutput ex: training)
      {
        String outNet = evaluate(ex.inputs);
        backPropagation(ex.outputs);
        tabConfusaoTraining[mapa.get(outNet)][mapa.get(ex.ladoVirado)]++;
        
      }
      for(InputOutput ex: validation)
      {
        String outNet = evaluate(ex.inputs);
        tabConfusaoValidation[mapa.get(outNet)][mapa.get(ex.ladoVirado)]++;
      }
      println("EPOCH: "+epoch+" ACURACIA TRAINING: " + getAccuracy(tabConfusaoTraining) + " ACURACIA VALIDATION: "+getAccuracy(tabConfusaoValidation));
      //printTabConfusao(tabConfusaoTraining);
      //printTabConfusao(tabConfusaoValidation);
      Collections.shuffle(training);
      Collections.shuffle(validation);
    }
  }
  
  void setRandom()
  {
    for(int i=0;i<inHdWeight.length;i++)for(int j=0;j<inHdWeight[i].length;j++)
      inHdWeight[i][j] = random(-1,1);
    for(int i=0;i<hdOutWeight.length;i++)for(int j=0;j<hdOutWeight[i].length;j++)
      hdOutWeight[i][j] = random(-1,1);
  }
  
  String getAccuracy(int[][] tabConfusao)
  {
    double sum=0;
    for(int[] i: tabConfusao)for(int j: i)sum+=j;
    double acuracia = 100*float(tabConfusao[0][0]+tabConfusao[1][1]+tabConfusao[2][2])/sum;
    return (""+acuracia).substring(0,min((""+acuracia).length(),5));
  }
  
  void printTabConfusao(int[][] tabConfusao)
  {
    for(int[] i: tabConfusao)
      {
        for(int j: i)print(j+ "\t");
        println();
      }
      println();
  }
  
  
  String evaluate(double[] in)
  {
    input = in;
    feedForward(input,hidden,inHdWeight);
    activation(hidden,hiddenActivation);
    feedForward(hiddenActivation,output,hdOutWeight);
    activation(output,outputActivation);
    outputActivationPrevious = outputActivation;
    int maxId=0;
    for(int i=1;i<output.length;i++)if(output[i]>output[maxId])maxId=i;
    
    return labelsOut[maxId];
  }
  
  void feedForward(double[] layer1, double[] layer2, double[][] weights)
  {
    for(int i=0;i<layer2.length;i++)layer2[i] = 0;
    for(int i=0;i<layer1.length;i++)
    {
      for(int j=0;j<layer2.length;j++)
      {
         layer2[j] += layer1[i]*weights[i][j];
      }
    }
    
  }
  
  void backPropagation(double[] saidaEsp)
  {
    double[] outputError = getError(output,saidaEsp);
    double[] deltaErrorOutput =  getDeltaErrorOutput(outputActivation,outputError);
    double[][] weightCorrectionHdOut = getWeightCorrection(hiddenActivation,deltaErrorOutput);
    double[] deltaErrorHidden =  getDeltaError(hiddenActivation,hdOutWeight,deltaErrorOutput);
    double[][] weightCorrectionInHd = getWeightCorrection(input,deltaErrorHidden);
    for(int i=0;i<hdOutWeight.length;i++)for(int j=0;j<hdOutWeight[i].length;j++)hdOutWeight[i][j] += weightCorrectionHdOut[i][j];
    for(int i=0;i<inHdWeight.length;i++)for(int j=0;j<inHdWeight[i].length;j++)inHdWeight[i][j] += weightCorrectionInHd[i][j];
  }
  
  double[][] getWeightCorrection(double[] layerActivation, double[] deltaError)
  {
    double[][] resp = new double[layerActivation.length][deltaError.length];
    for(int i=0;i<layerActivation.length;i++)for(int j=0;j<deltaError.length;j++)
      resp[i][j] = (-learningRate)*layerActivation[i]*deltaError[j];
    return resp;
  }
  
  double[] getDeltaErrorOutput(double[] out, double[] error)
  {
    double[] resp = new double[out.length];
    for(int i=0;i<out.length;i++) resp[i] = out[i]*(1-out[i])*error[i];
    return resp;
  }
  
  double[] getDeltaError(double[] layerActivation, double[][] weights, double[] deltaErrorNextLayer)
  {
   double[] resp = new double[layerActivation.length];   
   double sumError=0;
   for(int i=0;i<resp.length;i++)
   {
     for(int j=0;j<deltaErrorNextLayer.length;j++)sumError += weights[i][j]*deltaErrorNextLayer[j];
     resp[i] = layerActivation[i]*(1-layerActivation[i])*sumError;
   }
    return resp;
  }
  
  
  double[] getError(double[] output, double[] expected)
  {
    double[] res = new double[output.length];
    for(int i=0;i<output.length;i++)res[i] = (output[i] - expected[i]);
    return res;
  }
  
  void activation(double[] layer, double[] layerActivation)
  {
    for(int i=0;i<layerActivation.length;i++)
    {
      layerActivation[i] = 1/(1+Math.exp(-layer[i]));
      //layerActivation[i] = Math.max(0,layer[i]);
      //if(layer[i]>0)println(layer[i]);
    }
  }
  
  
  
}


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
    
    inputs = new double[]{distFrente,distEsq,distDir, distFood,foodInFront,foodInLeft,foodInRight,gradFront,gradLeft,size};
    outputs = new double[]{dir==Snake.WEST?1:0,dir==Snake.EAST?1:0,dir==Snake.NORTH?1:0};
    if(outputs[0]==1)ladoVirado = "LEFT";
    else if(outputs[1]==1)ladoVirado = "RIGHT";
    else ladoVirado = "FRONT";
  }
  
}

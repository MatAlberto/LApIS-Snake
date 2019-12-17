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
  int epochs = 100;
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

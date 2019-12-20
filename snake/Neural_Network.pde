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
  double learningRateFinal = 0.0001;
  int epochs = 200;
  double percentageValidation=0.20;
  double[] outputActivationPrevious;
  Layer[] layers;
  
  NeuralNetwork(int[] layerSizes,String[] labels)
  {
    layers = new Layer[layerSizes.length];
    for(int i=0;i<layerSizes.length;i++)layers[i] = new Layer(layerSizes[i]);
    for(int i=1;i<layerSizes.length-1;i++)
    {
      layers[i].nextLayer = layers[i+1];
      layers[i].previousLayer = layers[i-1];
      layers[i].initWeights();
    }
    layers[0].nextLayer = layers[1];
    layers[layers.length-1].previousLayer = layers[layers.length-2];
    layers[0].initWeights();
    labelsOut = labels;
  }
  
  String evaluate(double[] in)
  {
    layers[0].output = layers[0].inputSum = in;
    layers[0].feedForward();
    int maxId=0;
    if(layers[layers.length-1].size>1)
    {
      double[] output = layers[layers.length-1].output;
      for(int i=1;i<output.length;i++)if(output[i]>output[maxId])maxId=i;
      return labelsOut[maxId];
    }
    else
    {
      if(layers[layers.length-1].output[0]>0.5)return labelsOut[0];
      else return "NOT";
    }
    
    
  }
  
  void train(List<InputOutput> examples)
  {
    println(examples.size());
    HashMap<String,Integer> mapa = new HashMap<String,Integer>();
    for(int i=0;i<labelsOut.length;i++)mapa.put(labelsOut[i],i);
    
    Collections.shuffle(examples);
    ArrayList<InputOutput> training = new ArrayList<InputOutput>();
    ArrayList<InputOutput> validation = new ArrayList<InputOutput>();
    int i;
    for(i=0;(double)(i+1)/examples.size()<percentageValidation;i++)validation.add(examples.get(i));
    for(;i<examples.size();i++)training.add(examples.get(i));
    
    
    for(int epoch=0;epoch<epochs;epoch++)
    {
      int[][] tabConfusaoTraining = new int[labelsOut.length][labelsOut.length];
      int[][] tabConfusaoValidation = new int[labelsOut.length][labelsOut.length];
      for(InputOutput ex: training)
      {
        String outNet = evaluate(ex.inputs);
        layers[layers.length-1].backPropagation(ex.outputs,(learningRate-learningRateFinal)/(epoch+1));
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
  
  String getAccuracy(int[][] tabConfusao)
  {
    double sum=0;
    for(int[] i: tabConfusao)for(int j: i)sum+=j;
    double acuracia = 100*float(tabConfusao[0][0]+tabConfusao[1][1])/sum;
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
}


class Layer
{
  int size;
  double[] inputSum;
  double[] output;
  double[] deltaError;
  double[][] weight;

  Layer nextLayer=null,previousLayer=null;
  
  Layer (int sizeLayer)
  {
    inputSum = new double[sizeLayer];
    output = new double[sizeLayer];
    deltaError = new double[sizeLayer];
    size = sizeLayer;
  }
  
  void initWeights()
  {
    weight = new double[size+1][nextLayer.size];
    for(int i=0;i<weight.length;i++)for(int j=0;j<weight[i].length;j++)
      weight[i][j] = random(-1,1);
  }
  

  
  void activationSigmoid()
  {
    for(int i=0;i<output.length;i++)
    {
      output[i] = 1/(1+Math.exp(-inputSum[i]));
    }
  }
  
  void feedForward()
  {
    if(nextLayer==null)return;
    for(int i=0;i<nextLayer.inputSum.length;i++)nextLayer.inputSum[i] = 0;
    for(int i=0;i<output.length;i++)
    {
      for(int j=0;j<nextLayer.inputSum.length;j++)
      {
         nextLayer.inputSum[j] += output[i]*weight[i][j];
      }
    }
    nextLayer.activationSigmoid();
    nextLayer.feedForward();
  }
  
  void backPropagation(double[] saidaEsp, double learningRate)
  {
    if(nextLayer == null)
    {
      setDeltaErrorOutput(getError(saidaEsp));
    }
    else
    {
      setDeltaError();
      setWeightCorrection(learningRate);
    }
    if(previousLayer != null)previousLayer.backPropagation(saidaEsp,learningRate);
  }
  
  double[] getError(double[] expected)
  {
    double[] res = new double[output.length];
    for(int i=0;i<output.length;i++)res[i] = (output[i] - expected[i]);
    return res;
  }
  
  void setDeltaErrorOutput(double[] error)
  {
    for(int i=0;i<deltaError.length;i++) deltaError[i] = output[i]*(1-output[i])*error[i];
  }
  
  void setDeltaError()
  {
   double sumError=0;
   for(int i=0;i<deltaError.length;i++)
   {
     for(int j=0;j<nextLayer.deltaError.length;j++)sumError += weight[i][j]*nextLayer.deltaError[j];
     deltaError[i] = output[i]*(1-output[i])*sumError;
   }
  }
  
  void setWeightCorrection(double learningRate)
  {
    for(int i=0;i<output.length;i++)for(int j=0;j<nextLayer.deltaError.length;j++)
      weight[i][j] += (-learningRate)*output[i]*nextLayer.deltaError[j];
  }
  
  
}

class AlgGenetico
{
  Individuo[] population;
  Individuo atual;
  int generationCount=0;
  int individuoCount=0;
  double mutationChance = 0.3;
  double mutationOperationChance = 0.3;
  double reproductionOperationChance = 0.4;
  double cloneOperationChance = 0.3;
  int mutationCount,reproductionCount,cloneCount;
  
  AlgGenetico(int numberPop,int in,int hd, int out)
  {
    population = new Individuo[numberPop];
    for(int i=0;i<numberPop;i++)population[i] = new Individuo(in,hd,out);
    atual = population[0];
  }
  
  AlgGenetico(NeuralNetwork[] networks)
  {
    population = new Individuo[networks.length];
    for(int i=0;i<population.length;i++)
    {
      //population[i] = new Individuo(networks[i].inHdWeight,networks[i].hdOutWeight);
    }
    atual = population[0];
  }
  
  void setNextIndividuo()
  {
    tab.foodChooser = new Random(seedFood);
    if(individuoCount == population.length-1)
    {
      evolve();
      generationCount++;
      individuoCount=-1;
    }
    individuoCount++;
    atual = population[individuoCount];
    
    
  }
  
  void evolve()
  {
    Individuo[] newPopulation = new Individuo[population.length];
    for(int i = 0; i<newPopulation.length;i++)
    {
      Individuo novo;
      Individuo escolhido = getIndividuoByFitness();
      double operation = random(0,1);
      if(operation< mutationOperationChance)
      {
        novo = escolhido.mutate(mutationChance);
        mutationCount++;
      }
      else 
      {
        operation -= mutationOperationChance;
        if(operation < reproductionOperationChance)
        {
          novo = escolhido.reproduceWith2(getIndividuoByFitness());
          reproductionCount++;
        }
        else 
        {
          novo = escolhido.clone();
          cloneCount++;
        }
      }
      
      newPopulation[i] = novo;
    }
    population = newPopulation;
  }
  
  
  
  Individuo getIndividuoByFitness()
  {
    int sum=0;
    for(Individuo i: population)sum += i.fitness;
    int pos = (int)random(0,sum);
    for(Individuo i: population)
    {
      if(pos <= i.fitness)return i;
      pos -= i.fitness;
    }
    return null;
  }
  
  
  
}

class Individuo
{
  double[][] inHdWeight;
  double[][] hdOutWeight;
  int fitness = 1;
  
  Individuo(int in,int hd, int out)
  {
    inHdWeight = new double[in][hd];
    hdOutWeight = new double[hd][out];
  }
  
  Individuo(double[][] inHd, double[][] hdOut)
  {
    inHdWeight = inHd;
    hdOutWeight = hdOut;
  }
  
  void setRandom()
  {
    for(int i=0;i<inHdWeight.length;i++)for(int j=0;j<inHdWeight[i].length;j++)
      inHdWeight[i][j] = random(-1,1);
    for(int i=0;i<hdOutWeight.length;i++)for(int j=0;j<hdOutWeight[i].length;j++)
      hdOutWeight[i][j] = random(-1,1);
  }
  
  
  
  Individuo reproduceWith(Individuo ind)
  {
    Individuo novo = new Individuo(inHdWeight.length,hdOutWeight.length,hdOutWeight[0].length);
    for(int i=0;i<inHdWeight.length;i++)for(int j=0;j<inHdWeight[i].length;j++)
      novo.inHdWeight[i][j] = (inHdWeight[i][j]+ind.inHdWeight[i][j])/2;
    for(int i=0;i<hdOutWeight.length;i++)for(int j=0;j<hdOutWeight[i].length;j++)
      novo.hdOutWeight[i][j] = (hdOutWeight[i][j]+ind.hdOutWeight[i][j])/2;
    return novo;  
  }
  
  Individuo reproduceWith2(Individuo ind)
  {
    Individuo novo = new Individuo(inHdWeight.length,hdOutWeight.length,hdOutWeight[0].length);
    for(int i=0;i<inHdWeight.length;i++)for(int j=0;j<inHdWeight[i].length;j++)
      novo.inHdWeight[i][j] = (random(1)<0.5?inHdWeight[i][j]:ind.inHdWeight[i][j]);
    for(int i=0;i<hdOutWeight.length;i++)for(int j=0;j<hdOutWeight[i].length;j++)
      novo.hdOutWeight[i][j] = (random(1)<0.5?hdOutWeight[i][j]:ind.hdOutWeight[i][j]);
    return novo;  
  }
  
  
  Individuo mutate(double mutationChance)
  {
    Individuo novo = new Individuo(inHdWeight.length,hdOutWeight.length,hdOutWeight[0].length);
    for(int i=0;i<inHdWeight.length;i++)for(int j=0;j<inHdWeight[i].length;j++)
      if(random(1)<=mutationChance)novo.inHdWeight[i][j] += random(-0.5,0.5);
    for(int i=0;i<hdOutWeight.length;i++)for(int j=0;j<hdOutWeight[i].length;j++)
      if(random(1)<=mutationChance)novo.hdOutWeight[i][j] += random(-0.5,0.5);
    return novo;
  }
  
  Individuo clone()
  {
    Individuo novo = new Individuo(inHdWeight.length,hdOutWeight.length,hdOutWeight[0].length);
    for(int i=0;i<inHdWeight.length;i++)for(int j=0;j<inHdWeight[i].length;j++)novo.inHdWeight[i][j] = inHdWeight[i][j];
    for(int i=0;i<hdOutWeight.length;i++)for(int j=0;j<hdOutWeight[i].length;j++)novo.hdOutWeight[i][j] = hdOutWeight[i][j];
    return novo;
  }
  
  
}


#include "mex.h"
#include "qpboint.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
		/* Vlad's example code
         QPBO* q;

		q = new QPBO(2, 1); // max number of nodes & edges
		q->AddNode(2); // add two nodes

		q->AddUnaryTerm(0, 0, 2); // add term 2*x
		q->AddUnaryTerm(1, 3, 6); // add term 3*(y+1)
		q->AddPairwiseTerm(0, 1, 2, 3, 4, 6); // add term (x+1)*(y+2)

		q->Solve();
		q->ComputeWeakPersistencies();

		int x = q->GetLabel(0);
		int y = q->GetLabel(1);
		mexPrintf("Solution: x=%d, y=%d\n", x, y);

		return;
     */
    
    // first read in input arguments
    if(nrhs != 2 && nrhs != 3)
        mexErrMsgTxt("Requires either two or three input parameters: see 'help qpbo' for usage!!!\n");
    if(nlhs != 1)
        mexErrMsgTxt("Only allows one output parameter: see 'help qpbo' for usage!!!\n");
    
    int numEdges = mxGetM(prhs[0]);
    int weightsPerEdge = mxGetN(prhs[1]);
    bool unaryTerm;
    if(numEdges < 1)
        mexErrMsgTxt("Must have at least one edge: see 'help qpbo' for usage!!!\n");
    if(mxGetN(prhs[0])!=2)
        mexErrMsgTxt("Edge list must connect exactly two nodes: see 'help qpbo' for usage!!!\n");
    if(mxGetM(prhs[1]) != numEdges)
        mexErrMsgTxt("Each edge must have a weight: see 'help qpbo' for usage!!!\n");
    if(weightsPerEdge != 1 && weightsPerEdge != 4)
        mexErrMsgTxt("Weight matrix can only have either 1 or 4 columns: see 'help qpbo' for usage!!!\n");
    
    //// prepare input and output variables
    double *pEdgeList;
    double *pWeights;
    double *pNodeLabels;
    double *pUnaryTerms;
    
    // inputs
    pEdgeList = mxGetPr(prhs[0]);    
    pWeights = mxGetPr(prhs[1]);

    // first determine the number of nodes
    int numNodes = 0;
    int temp;
    for(int i=0;i<2*numEdges;i++)
    {
        temp = int(pEdgeList[i]);
        if(temp > numNodes)
            numNodes = temp;
    }
    
    if(nrhs == 3)
    {
        unaryTerm = true;
        if(mxGetM(prhs[2]) != numNodes && mxGetN(prhs[2]) != 2)
            mexErrMsgTxt("Unary term matrix must be of size numNodes x 2: see 'help qpbo' for usage!!!\n");
    }
    else
        unaryTerm = false;
    if(unaryTerm)
        pUnaryTerms = mxGetPr(prhs[2]);
        
    if(numNodes <= 1)
        mexErrMsgTxt("Edge list must imply at least 2 nodes: see 'help qpbo' for usage!!!\n");
    
    // outputs
    plhs[0] = mxCreateDoubleMatrix(numNodes,1,mxREAL);
    pNodeLabels = mxGetPr(plhs[0]);
        
    //// perform computation
    
    QPBO* q;

    q = new QPBO(numNodes,numEdges); // max number of nodes & edges
    q->AddNode(numNodes);
    
    //// prepare pairwise terms 
    //(in case with weight matrix (per edge) is a multiple of identity matrix)
    if(weightsPerEdge == 1)
    {
        if(unaryTerm)
           for(int i=0;i<numNodes;i++)
            {
                   q->AddUnaryTerm(i,int(pUnaryTerms[i]),int(pUnaryTerms[i+numNodes]));
            }
        for(int i=0;i<numEdges;i++)
        {
            q->AddPairwiseTerm(pEdgeList[i]-1,pEdgeList[i+numEdges]-1,
                0, pWeights[i], pWeights[i] , 0); 
        }
    }
    //(in case with weight matrix is arbitrary)
    if(weightsPerEdge == 4)
    {
        if(unaryTerm)
           for(int i=0;i<numNodes;i++)
            {
                   q->AddUnaryTerm(i,int(pUnaryTerms[i]),int(pUnaryTerms[i+numNodes]));
            }
        for(int i=0;i<numEdges;i++)
        {
            q->AddPairwiseTerm(pEdgeList[i]-1,pEdgeList[i+numEdges]-1,
                pWeights[i], pWeights[i+numEdges*1], pWeights[i+numEdges*2] , pWeights[i+numEdges*3]);  
        }
    }

    q->Solve();
	q->ComputeWeakPersistencies();
   
    for(int j=0;j<numNodes;j++)
    {
        pNodeLabels[j] = q->GetLabel(j);
    }
    
    delete q;
    
}
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace imgRenkoRenderFrameWork
{

    public class TangentsBaker : MonoBehaviour
    {
        public ScriptableObject Baker;
         TArray[] tangentsList;
        // Start is called before the first frame update
        void Awake()
        {
            int i = 0;
            PlugTangentTools tool = (PlugTangentTools)Baker;
            tangentsList = tool.tangentsList;
         
            MeshFilter[] meshFilters = gameObject.GetComponentsInChildren<MeshFilter>();
            for (i = 0; i != meshFilters.Length; ++i)
            {
               
                MeshFilter meshFilter = meshFilters[i];
               
                Mesh mesh = meshFilter.sharedMesh;
               
                TArray t = new TArray();
                mesh.tangents = tool.tangentsList[i].tangentsList;
            }
           // Debug.Log(me);
            SkinnedMeshRenderer[] skinMeshRenders = gameObject.GetComponentsInChildren<SkinnedMeshRenderer>();
            for (int r = 0; r != skinMeshRenders.Length; ++r) { 
                SkinnedMeshRenderer skinMeshRender = skinMeshRenders[r];
                Mesh mesh = skinMeshRender.sharedMesh;
                Debug.LogWarning(mesh.vertices.Length);
                Debug.LogWarning(tool.tangentsList[r + i].tangentsList.Length);
                mesh.tangents = tool.tangentsList[r +  i].tangentsList;
            }
        }

        // Update is called once per frame
        void Update()
        {

        }
    }
}
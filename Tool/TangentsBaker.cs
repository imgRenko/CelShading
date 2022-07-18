using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace imgRenkoRenderFrameWork
{

    public class TangentsBaker : MonoBehaviour
    {
        public string Path;
         TArray[] tangentsList;
        // Start is called before the first frame update
        void Awake()
        {
            if (Path == "" || this.gameObject.activeSelf == false)
                return;
            int i = 0;
            PlugTangentTools tool = Resources.Load<PlugTangentTools>(Path);
            tangentsList = tool.tangentsList;
         
            MeshFilter[] meshFilters = gameObject.GetComponentsInChildren<MeshFilter>(true);
            for (i = 0; i != meshFilters.Length; ++i)
            {
               
                MeshFilter meshFilter = meshFilters[i];
               
                Mesh mesh = meshFilter.sharedMesh;
               
               
                if (tool.tangentsList[i].Name == meshFilter.gameObject.name || tool.tangentsList[i].Name == "" )
                    mesh.tangents = tool.tangentsList[i].tangentsList;
            }
           // Debug.Log(me);
            SkinnedMeshRenderer[] skinMeshRenders = gameObject.GetComponentsInChildren<SkinnedMeshRenderer>();
            for (int r = 0; r != skinMeshRenders.Length; ++r) { 
                SkinnedMeshRenderer skinMeshRender = skinMeshRenders[r];
                Mesh mesh = skinMeshRender.sharedMesh;
                //  Debug.LogWarning(mesh.vertices.Length);
                //  Debug.LogWarning(tool.tangentsList[r + i].tangentsList.Length);
                if (tool.tangentsList[r+i].Name == skinMeshRender.gameObject.name || tool.tangentsList[r + i].Name == "")
                    mesh.tangents = tool.tangentsList[r +  i].tangentsList;
            }
        }

        // Update is called once per frame
        void Update()
        {

        }
    }
}
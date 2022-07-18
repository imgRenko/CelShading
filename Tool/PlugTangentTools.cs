using UnityEditor;
using UnityEngine;
using System.Collections.Generic;
using System;
namespace imgRenkoRenderFrameWork
{
    [Serializable]
    public class TArray {
        public string Name;
        public Vector4[] tangentsList;
    }
    [Serializable]
    [CreateAssetMenu(fileName ="TangentsBaker",menuName ="Tangents Baker")]
    public class PlugTangentTools : ScriptableObject
    {

        
         List<TArray> _TangentsList = new List<TArray>();
        [SerializeField]
        public TArray[] tangentsList;
        public GameObject tarMesh;
       
        public TArray[] WirteAverageNormalToTangentToos()
        {
            _TangentsList.Clear();
            MeshFilter[] meshFilters = tarMesh.GetComponentsInChildren<MeshFilter>();
            foreach (var meshFilter in meshFilters)
            {
                Mesh mesh = meshFilter.sharedMesh;
                TArray t = new TArray();
                t.Name = meshFilter.gameObject.name;
                t.tangentsList = WirteAverageNormalToTangent(mesh);
                _TangentsList.Add(t);
            }
            SkinnedMeshRenderer[] skinMeshRenders = tarMesh.GetComponentsInChildren<SkinnedMeshRenderer>();
            foreach (var skinMeshRender in skinMeshRenders)
            {
                Mesh mesh = skinMeshRender.sharedMesh;
                TArray t = new TArray();
                t.Name = skinMeshRender.gameObject.name;
                t.tangentsList = WirteAverageNormalToTangent(mesh);
                _TangentsList.Add(t);
            }
            tangentsList = _TangentsList.ToArray();
            return tangentsList;
        }

        private Vector4[] WirteAverageNormalToTangent(Mesh mesh)
        {
            var averageNormalHash = new Dictionary<Vector3, Vector3>();
            for (var j = 0; j < mesh.vertexCount; j++)
            {
                if (!averageNormalHash.ContainsKey(mesh.vertices[j]))
                {
                    averageNormalHash.Add(mesh.vertices[j], mesh.normals[j]);
                }
                else
                {
                    averageNormalHash[mesh.vertices[j]] =
                        (averageNormalHash[mesh.vertices[j]] + mesh.normals[j]).normalized;
                }
            }

            var averageNormals = new Vector3[mesh.vertexCount];
            for (var j = 0; j < mesh.vertexCount; j++)
            {
                averageNormals[j] = averageNormalHash[mesh.vertices[j]];
            }

            var tangents = new Vector4[mesh.vertexCount];
            for (var j = 0; j < mesh.vertexCount; j++)
            {
                tangents[j] = new Vector4(averageNormals[j].x, averageNormals[j].y, averageNormals[j].z, 0);
            }
            mesh.tangents = tangents;
            
            return tangents;
        }
    }
}
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace imgRenkoRenderFrameWork
{
    public class DLightController : MonoBehaviour
    {
        [Header("All Renderer")]
        public SkinnedMeshRenderer[] Renderers;
        public bool autoGet = true;
        [Header("DLight")]
        public Light directLight;
        [Header("Param")]
        public float minFloat = 0.1f;
        public float Offset = 0.1f;
        public float maxDLightIntensity = 4.0f;
        // Start is called before the first frame update
        void Start()
        {
            if (autoGet)
                Renderers = this.gameObject.GetComponentsInChildren<SkinnedMeshRenderer>();
        }

        // Update is called once per frame
        void Update()
        {
            foreach (var p in Renderers)
            {
                foreach (var material in p.materials)
                {
                    material.SetFloat("_ShadowAutoAdjustByLight", (minFloat + Offset + 1) * (directLight.intensity / maxDLightIntensity));
                }
            }
        }
    }
}
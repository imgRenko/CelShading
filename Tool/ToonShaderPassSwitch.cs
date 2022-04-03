using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace imgRenkoRenderFrameWork
{
    public class ToonShaderPassSwitch : MonoBehaviour
    {
        public bool onForwardLit = true;
        public bool onOutline = true;
        public bool onShadowCaster = true;
        public bool onDepthOnly = true;
        public bool onHairShadow = true;
        public bool onRimLight = true;
    }
}
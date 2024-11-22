## ArgoCD란?
- GitOps 방식(애플리케이션의 배포와 운영에 관련된 모든 요소들을 Git에서 관리하는 방식)으로 Kubernetes 애플리케이션을 관리하고 배포하는 데 사용되는 선언적 지속적 배포(CD, Continuous Deployment) 도구
- 클러스터 상태를 Git 리포지토리에 저장된 선언적 상태(예: Helm 차트, Kustomize, YAML 파일 등)와 동기화
  ![image](https://github.com/user-attachments/assets/ba663fe4-6a68-406f-a8e1-43b8fbb47b87)

## ArgoCD를 사용하여 얻을 수 있는 이점
- 애플리케이션 상태가 Git에 저장되므로 구성 관리와 버전 관리가 간단하며 Git 커밋만으로 변경 이력 추적 가능
- Git에 변경 사항이 반영되면 클러스터가 자동으로 동기화되므로 배포 프로세스가 간소화되며 반복 작업이 줄어들어 효율성이 증가함
- Git의 특정 커밋으로 빠르게 롤백 가능
- Kubernetes와 자연스럽게 통합되어 별도의 외부 배포 도구를 사용하지 않아도 됨
  
## ArgoCD 설치 및 설정

- ArgoCD 설치
    
    ```bash
    kubectl create namespace argocd
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    ```
    - argocd라는 namespace를 만들어서 argocd만 별도로 관리할 수 있도록 함
    - 시스템 외부에 있는 yaml 파일을 이용하여 ArgoCD 설치
- ArgoCD 접근 설정
    
    ```bash
    kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
    kubectl get svc argocd-server -n argocd
    ```
    - argoCD를 외부에서 접근하기 위해서 argocd-server 서비스를 LoadBalancer type으로 변경해준다.
    
- 서비스 주소로 접속
  
  ![images](https://github.com/user-attachments/assets/555bfebd-3770-4289-ba25-90a6101a6770)

- 로그인
    - 아이디 :  admin
    - 비밀번호 알아내기
        
        ```bash
        kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
        ```
        

## ArgoCD GitOAuth로 접속하는 방법
### OAuth 앱을 사용할 때 얻을 수 있는 이점
- OAuth 토큰을 사용함
    - 비밀번호 관리의 복잡성을 줄이고 보안을 강화합니다.
    - 토큰은 만료 시간을 설정할 수 있어, 필요시 주기적으로 갱신하여 보안을 강화할 수 있음
    - OAuth를 통해 각 토큰에 특정 권한만 부여할 수 있어 세밀한 권한 설정을 할 수 있음
    - 수동으로 자격 증명을 관리하지 않아도 
- 중앙 집중화된 인증 관리
    - OAuth는 조직 내 사용자와 팀의 인증을 중앙에서 관리하기 때문에, Git 리포지토리 접근 권한을 팀이나 조직의 구조에 맞게 효율적으로 설정 가능
    -  Git 호스팅 서비스와 쉽게 통합 가능하여 일관된 인증 및 권한 관리를 제공
- 사용자 또는 CI/CD 도구가 추가 인증 절차를 거치지 않고 원활하게 Git 리포지토리와 상호작용할 수 있음

### OAuth앱 생성

- 앱 생성
    - organization의 settings → Developer settings → OAuth Apps 선택
    
    ![image](https://github.com/user-attachments/assets/1d7a97be-7c4d-4927-ae53-785d6a24c92e)
    
   ![화면 캡처 2024-11-21 185858](https://github.com/user-attachments/assets/9643cc97-28e8-43a0-a3ed-f2672f615530)
    
    - Application Name : OAuth의 이름을 지정
    - Homepage URL : ArgoCD의 홈페이지 주소
    - Authorization callback URL : ArgoCD 홈페이지 주소/api/dex/callback 형식
- OAuths Client ID와 Client secrets
    
    ![화면 캡처 2024-11-21 190103](https://github.com/user-attachments/assets/0625b7a7-1008-4b3f-a9f9-e14d1ed0d6bd)
    
    - Client ID와 Client secrets는 argoCD의 컨피그맵에 사용됨
    - Client secrets는 Generate a new client secret를 눌러서 생성함
        - 단, 버튼 누른 그 때만 확인이 가능하고 그 다음에는 확인할 수 없음

### 컨피그맵 수정

```bash
kubectl edit cm argocd-cm -n argocd
```

![화면 캡처 2024-11-21 192915](https://github.com/user-attachments/assets/fd86d28c-01a7-4975-8769-484186ab3f62)
### RBAC 수정

```bash
kubectl edit cm argocd-rbac-cm -n argocd
```
- RBAC : 사용자와 그룹에게 특정 리소스에 접근 가능하게 하고, 특정 작업을 수행할 수 있도록 제어하는 데 사용
- RBAC의 role : 특정 작업(예: 애플리케이션 보기, 생성, 동기화, 삭제 등)을 수행할 수 있는 권한을 정의하는 역할
- RBAC 설정을 하지 않는다면?
    - 대부분의 사용자 계정이 어떠한 작업도 수행하지 못할 가능성이 존재함
    - 모든 사용자가 기본 관리자 계정을 사용하게 될 수 밖에 없는 위험성이 존재하며 관리 효율성이 떨어
    - 여러 사용자나 팀이 접근해야 하는 환경에서 RBAC가 설정되지 않으면 충돌 및 혼란이 발생할 가능성이 존재함

![화면 캡처 2024-11-21 193034](https://github.com/user-attachments/assets/1e4d9b16-d515-4b41-9119-d14e64d70e20)

### 접속 화면

![화면 캡처 2024-11-21 193321](https://github.com/user-attachments/assets/0a6c39e7-7094-4a2b-96b3-e7bd98b1a1a1)

GitHub 로그인 버튼이 추가되었음

- GitHub 계정 로그인하면 접속이 됨
    
    ![화면 캡처 2024-11-21 203616](https://github.com/user-attachments/assets/6efd8d06-b945-4da0-9389-cc06e549cfea)
  
## ArgoCD Repo 연결하기 (GitHub 방식)

### GitHub Apps 생성

- organization의 settings → Developer settings → GitHub Apps 선택
- New GitHub App 선택하여 생성
    
    ![화면 캡처 2024-11-21 204331](https://github.com/user-attachments/assets/cd89cb22-6f96-4fbd-a3ea-cae21e423368)
    
    ![화면 캡처 2024-11-21 204412](https://github.com/user-attachments/assets/a335f0e4-23e9-4e04-9e49-15d8dd51ae99)
    
    - GitHub App name : GitHub App 이름
    - Homepage URL : 연결한 repository의 URL
    
    ![화면 캡처 2024-11-21 204736](https://github.com/user-attachments/assets/d79a6f97-a86a-43ab-9fb6-a2603912bf92)
    
    - Webhook 해제해도 됨(GitHub App이 자동으로 지원함)
      
    ※ Webhook 이란?
  
        - 이벤트가 발생할 때 이를 외부 시스템에 알리거나 데이터를 전달하는 데 사용하는 이벤트 기반 통신 방식
        - Webhook의 이점
            - 이벤트 발생 시 즉각적으로 외부 시스템에 알림을 전송하기 때문에, 데이터를 실시간으로 동기화할 수 있음
            - 필요한 경우에만 데이터를 전송할 수 있게 하여서 네트워크 효율성 증대
            - HTTP 프로토콜을 이용하여 설치나 관리가 간단함 
    
    ![화면 캡처 2024-11-21 204706](https://github.com/user-attachments/assets/baf89150-687e-4e7e-951d-47db73bd6c29)
    
    - Repository Permissions 선택:
        - Contents: Read-only
        - Metadata: Read-only
    - Organization Permissions 선택:
        - Self-hosted runners: Read-only
    - Only on this account 선택
- 생성 후 화면
    
    ![화면 캡처 2024-11-21 205352](https://github.com/user-attachments/assets/e3082899-a593-4412-8610-e6e5735aee8b)
    
    - App ID, Client ID : Repository 연결 할 때 사용할 값
    - Generate a new client secret를 눌러서 Client secrets를 만들기
        - 단, 버튼 누른 그 때만 확인이 가능하고 그 다음에는 확인할 수 없음
    - Generate a private key를 눌러서 private key 다운로드
        
       ![화면 캡처 2024-11-21 205731](https://github.com/user-attachments/assets/ef6c09bc-3601-405b-b19b-575e6ba64bdc))
        
- App을 Repo에 설치
    - Install App → Install 클릭
    
    ![화면 캡처 2024-11-21 205833](https://github.com/user-attachments/assets/bcf56ed9-5924-4804-94f6-d96738c8b722)
    
    ![화면 캡처 2024-11-21 205931](https://github.com/user-attachments/assets/55ea046a-9fcf-4c3c-935f-7d90641c070a))
    
    ![화면 캡처 2024-11-21 210004](https://github.com/user-attachments/assets/372d34b7-08bd-43c9-813e-cfc868d84d9c)
    
    - 생성 후 도메인에서 맨 끝 숫자부분이 Installation ID임

### Repo 연결
- Settings → Repositories → CONNECT REPO 선택
- GitHub App을 사용할 때 얻을 수 있는 이점
    - GitHub App은 사용자 계정과 독립적으로 작동하여 특정 사용자의 계정 상태에 영향을 받지 않음
    - GitHub App을 사용하면 단일 앱 인스턴스로 모든 리포지토리를 관리 할 수 있음
    - GitHub App은 자동으로 Webhook을 지원하여 리포지토리에서 발생하는 이벤트를 실시간으로 수신 가능

![화면 캡처 2024-11-21 203745](https://github.com/user-attachments/assets/7d3b1723-b6a3-46f6-9dae-3d001add67da)

![화면 캡처 2024-11-21 203848](https://github.com/user-attachments/assets/9c48d57f-6a2e-4b31-8f0d-73d6afd6929e)
    
![화면 캡처 2024-11-21 203932](https://github.com/user-attachments/assets/b35ceabe-620b-4964-ac78-1ad6ba51a502)
    
![화면 캡처 2024-11-21 210612](https://github.com/user-attachments/assets/7e81ee08-cfe2-4930-bb30-6d0409bbba82)
